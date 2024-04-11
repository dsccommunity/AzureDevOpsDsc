[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification='Required for output within the DSC Resource')]

$references = @{}
$variables = @{}
$parameters = @{}

function SetVariables {
    param (
        [hashtable] $Source,
        [hashtable] $Target
    )

    foreach ($key in $Source.Keys) {
        $Target.Add($key, $Source[$key])

        $varName = $key.Replace(".", "_")
        New-Variable -Name $varName -Value $Source[$key] -Scope Script -Force | Out-Null
        New-Item -Path env:$varName -Value $Source[$key] -ErrorAction SilentlyContinue
    }
}

function GetDefaultValues {
    param (
        [hashtable] $Source
    )

    $values = @{}
    foreach ($key in $Source.Keys) {
        $values.Add($key, $Source[$key].defaultValue)
    }

    return $values
}

function parameters {
    param ([string] $Name)

    $value = $parameters[$Name]
    return $value
}

function variables {
    param ([string] $Name)

    $value = $variables[$Name]
    return $value
}

function reference {
    param ([string] $Name)

    $value = $references[$Name]
    return $value
}

function equals {
    param ([string] $Left, [string] $Right)

    return [System.String]::Equals($Left, $Right)
}

function not {
    param ([Boolean] $Statement)

    return $Statement -ne $true
}

Function Sort-DependsOn {
    [OutputType([System.Collections.ArrayList])]
    param(
        [Object[]]$PipelineResources
    )

    #
    # Order the Tasks according to DependsOn Property

    Write-Verbose "Separating resources with and without DependsOn property" -Verbose
    $ResourcesWithoutDependsOn, $ResourcesWithDependsOn = $PipelineResources.Where({ $null -eq $_.DependsOn }, 'Split')

    #
    # Format the DependsOn Property by ensuring the Resource parent is before the child.

    Write-Verbose "Initializing task list as an ArrayList" -Verbose
    $TaskList = [System.Collections.ArrayList]::New()

    #
    # Enumerate the Resources with DependsOn Property

    ForEach ($ResourceObject in $ResourcesWithDependsOn) {

        Write-Verbose "Processing resource with DependsOn: [$($ResourceObject.Type)/$($ResourceObject.Name)]" -Verbose

        # Get the DependsOn Property and format it into a hashtable.
        $DependsOn = $ResourceObject.DependsOn | ForEach-Object {
            $split = $_.Split("/")
            @{
                Type = "{0}/{1}" -f $split[0], $split[1]
                Name = $split[2..$split.length] -join "/"
            }
        }

        #
        # Test to see if the Resource DependsOn is the current Resource. If so, throw an error.
        if (($DependsOn.Name -eq $ResourceObject.Name) -and ($DependsOn.Type -eq $ResourceObject.Type)) {
            throw "Resource [$($ResourceObject.Type)/$($ResourceObject.Name)] DependsOn Resource cannot be the same Resource."
        }

        # Enumerate the DependsOn Property and locate the Resource within ResourceConfiguration.
        # Order the Resources by the index position of the Resource within ResourceConfiguration.
        # We only need the lowest index number since the resource can be inserted before the Resource.

        Write-Verbose "Determining the top index for resource insertion based on dependencies" -Verbose
        $ResourceTopIndex = $DependsOn | ForEach-Object {
            $ht = $_
            # Locate the index position of the Resource within ResourceConfiguration. If there are multiple resources with the same name, sort by the lowest index number.
            0 .. $PipelineResources.Count | Where-Object {
                ($ht.Type -eq $TaskList[$_].Type) -and
                ($ht.Name -eq $TaskList[$_].Name)
            }
        } | Sort-Object | Select-Object -First 1

        # If the Resource is not found, add it to the end of the list.
        if ($null -eq $ResourceTopIndex) {
            # Write a Warning
            Write-Warning "Resource [$($DependsOn.Type)/$($DependsOn.Name)] DependsOn Resource not found. Adding to the end of the list."
            # Add the Resource to the end of the list.
            $null = $TaskList.Add($ResourceObject)
        }
        # If the Resource is found, insert it before the Resource.
        else {

            Write-Verbose "Inserting resource at calculated index position: $ResourceTopIndex" -Verbose
            if ($ResourceTopIndex -eq 0) { $null = $TaskList.Insert(0, $ResourceObject) }
            else { $null = $TaskList.Insert($ResourceTopIndex - 1, $ResourceObject) }

        }
    }

    #
    # Add ResourcesWithoutDependsOn to the top of the task list.
    Write-Verbose "Adding resources without DependsOn to the top of the task list" -Verbose
    $ResourcesWithoutDependsOn | ForEach-Object {
        $null = $TaskList.Insert(0, $_)
    }

    $TaskList

}

function Invoke-DscConfiguration {
    # Declare parameters for the function with default values and validation where needed
    param (
        [string] $FilePath, # The path to the configuration file (.yaml/.yml or .json)
        [ValidateSet("Test", "Set")] # Ensures that Mode can only be 'Test' or 'Set'
        [string] $Mode = "Test" # Default mode is 'Test', can be set to 'Set' for applying changes
    )
    # Determine the file extension of the provided FilePath
    $fileExtension = [System.IO.Path]::GetExtension($FilePath)
    Write-Verbose "File extension determined: $fileExtension" -Verbose

    # Load the configuration from the YAML or JSON file into the $pipeline variable
    if ($fileExtension -eq ".yaml" -or $fileExtension -eq ".yml") {
        $pipeline = get-content $FilePath | ConvertFrom-Yaml
        Write-Verbose "Loaded YAML configuration from file: $FilePath" -Verbose
    }
    elseif ($fileExtension -eq ".json") {
        $pipeline = get-content $FilePath | ConvertFrom-Json -AsHashtable
        Write-Verbose "Loaded JSON configuration from file: $FilePath" -Verbose
    }

    # Clear any existing data in these hashtables before populating them
    $parameters.Clear()
    $variables.Clear()
    $references.Clear()
    Write-Verbose "Cleared existing data in parameters, variables, and references hashtables" -Verbose

    # Retrieve default values for parameters and set variables based on the pipeline's content
    $defaultValues = GetDefaultValues -Source $pipeline.parameters
    SetVariables -Source $pipeline.variables -Target $variables
    SetVariables -Source $defaultValues -Target $parameters
    Write-Verbose "Retrieved default values for parameters and set variables based on pipeline content" -Verbose

    # Sort the tasks based on their dependencies to ensure correct execution order
    $tasks = Sort-DependsOn -PipelineResources $pipeline.resources
    Write-Verbose "Sorted tasks based on dependencies" -Verbose

    # Loop through each task/resource and process it according to its configuration
    foreach ($task in $tasks) {

        Write-Verbose "Processing resource: [$($task.type)/$($task.name)]" -Verbose

        # Evaluate the condition script block if it exists, and skip the task if the condition returns false
        if ($null -ne $task.condition) {
            $condition = [scriptblock]::New($task.condition)
            if ($condition.Invoke() -eq $false) {
                Write-Verbose "Skipping resource due to condition: [$($task.type)/$($task.name)]" -Verbose
                continue
            }
        }

        # Extract the module name and resource type from the task's type property
        $module = $task.type.Split("/")[0]
        $resourceType = $task.type.Split("/")[1]
        Write-Verbose "Extracted module name: $module and resource type: $resourceType" -Verbose

        # Replace any variables in the properties with their actual values
        $Property = @{}
        foreach ($key in $task.properties.Keys) {
            $inputValue = $ExecutionContext.InvokeCommand.ExpandString($task.properties[$key])
            $Property.Add($key, $inputValue)
        }
        Write-Verbose "Replaced variables in properties with actual values" -Verbose

        # Prepare parameters for invoking the DSC resource using the 'Test' method
        $resourceParameters = @{
            Name = $resourceType
            ModuleName = $module
            Method = "Test"
            Property = $Property
        }
        Write-Verbose "Prepared parameters for 'Test' invocation of DSC resource" -Verbose

        # Execute the 'Test' method to determine if the state is as desired
        $result = Invoke-DscResource @resourceParameters
        Write-Verbose "Executed 'Test' method for DSC resource: [$($task.type)/$($task.name)]" -Verbose

        # If not in the desired state and Mode is 'Set', execute the 'Set' method to apply changes
        if ($result.InDesiredState) {
            Write-Verbose "Resource is in the desired state: [$($task.type)/$($task.name)]" -Verbose
        }
        elseif ($Mode -eq "Set") {
            $resourceParameters.Method = "Set"
            try {
                Invoke-DscResource @resourceParameters
                Write-Verbose "Executed 'Set' method to make changes: [$($task.type)/$($task.name)]" -Verbose
            }
            catch {
                Write-Error "Failed to apply changes with 'Set' method: [$($task.type)/$($task.name)]" -Verbose
            }
        }
        else {
            Write-Verbose "Change needed, but mode is not set to 'Set': [$($task.type)/$($task.name)]" -Verbose
        }

        # Remove all non-mandatory properties to avoid errors when calling the 'Get' method
        $resource = Get-DscResource -Module $module -Name $resourceType
        $mandatoryProperties = @()
        $resource.Properties | Where-Object { $_.IsMandatory } | ForEach-Object { $mandatoryProperties += $_.Name }
        Write-Verbose "Identified mandatory properties for DSC resource: [$($task.type)/$($task.name)]" -Verbose

        $getProperties = @{}
        foreach ($key in $resourceParameters.Property.Keys) {
            if ($mandatoryProperties.Contains($key)) {
                $getProperties.Add($key, $resourceParameters.Property[$key])
            }
        }
        Write-Verbose "Filtered properties for 'Get' method invocation of DSC resource: [$($task.type)/$($task.name)]" -Verbose

        # Use the 'Get' method to retrieve the current state after applying changes if any
        $resourceParameters.Method = "Get"
        $resourceParameters.Property = $getProperties
        $output_var = Invoke-DscResource @resourceParameters
        Write-Verbose "Retrieved current state with 'Get' method for DSC resource: [$($task.type)/$($task.name)]" -Verbose

        # Store the output of the 'Get' operation in a reference table for later use
        $references.Add($task.name, $output_var)
        Write-Verbose "Stored output of 'Get' operation in references table for resource: [$($task.type)/$($task.name)]" -Verbose
    }

}

Function Build {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType 'Container' })]
        [String]
        $OutputPath
    )

    <#
    .SYNOPSIS
    This script builds the Azure DevOps DSC configuration.

    .DESCRIPTION
    The script imports necessary modules and sets the location to the example configuration folder. It then creates a Datum structure using the definition file Datum.yml. It iterates through each node in the Datum structure and retrieves the node groups. It creates a configuration data hashtable with the node groups and the Datum structure. It resolves the resources, parameters, conditions, and variables using the Resolve-Datum function.

    .PARAMETER None

    .EXAMPLE
    .\build.ps1
    #>

    $scriptBlock = {
        param($OutputPath)

        # Import the YAML module for handling YAML files
        # Import the Datum module for configuration data management
        Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\Datum\powershell-yaml\0.4.7\powershell-yaml.psd1'
        Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\Datum\datum\0.40.1\datum.psd1'
        Write-Verbose "Modules for YAML and Datum have been imported" -Verbose

        # Change the current directory to the Example Configuration directory
        Set-Location 'C:\Temp\AzureDevOpsDSC\Example Configuration'
        Write-Verbose "Changed directory to Example Configuration" -Verbose

        # Clear the output directory
        Get-ChildItem -LiteralPath $OutputPath -File | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Verbose "Cleared the output directory at path: $OutputPath" -Verbose

        # Create a new Datum structure based on the provided definition file 'Datum.yml'
        $Datum = New-DatumStructure -DefinitionFile Datum.yml
        Write-Verbose "Datum structure created from definition file 'Datum.yml'" -Verbose

        # Iterate over each node defined in the Datum structure
        ForEach ($NodeName in $Datum.AllNodes.psobject.properties) {
            Write-Verbose "Processing node: $($NodeName.Name)" -Verbose

            # Retrieve the NodeGroups for the current node and store them in an array
            $AllNodes = $Datum.AllNodes."$($NodeName.Name)".NodeGroups | ForEach-Object { $_ }
            Write-Verbose "Retrieved NodeGroups for node: $($NodeName.Name)" -Verbose

            # Create a hashtable to hold configuration data, including all nodes and the Datum structure itself
            $ConfigurationData = @{
                AllNodes = $AllNodes
                Datum    = $Datum
            }
            Write-Verbose "Configuration data hashtable created for node: $($NodeName.Name)" -Verbose

            # Access the AllNodes and Baseline properties from the configuration data
            $Node = $ConfigurationData.AllNodes
            $Baseline = $ConfigurationData.Datum.Baselines
            Write-Verbose "Accessed AllNodes and Baseline properties for node: $($NodeName.Name)" -Verbose

            # Resolve and store the resources, parameters, conditions, and variables using the Resolve-Datum function
            $configuration = @{
                resources  = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Resources'
                parameters = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Parameters'
                conditions = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Conditions'
                variables  = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Variables'
            }
            Write-Verbose "Resolved resources, parameters, conditions, and variables for node: $($NodeName.Name)" -Verbose

            # Convert the configuration to YAML format and save it to the output file
            $configuration | ConvertTo-Yaml | Out-File "$OutputPath\$($NodeName.Name).yml"
            Write-Verbose "Configuration for node: $($NodeName.Name) has been converted to YAML and saved to file" -Verbose
        }
    }

    #
    # Run the following powershell in a seperate thread

    # Create a runspace (thread) for the script block to run in
    $runspace = [runspacefactory]::CreateRunspace()

    # Open the runspace
    $runspace.Open()

    # Create a PowerShell instance and attach the script block and runspace
    $powerShellInstance = [powershell]::Create().AddScript($scriptBlock).AddArgument($OutputPath)
    $powerShellInstance.Runspace = $runspace

    # Run the PowerShell script asynchronously
    $asyncResult = $powerShellInstance.BeginInvoke()

    # Optionally, you can handle the output of the script after it has completed
    $scriptOutput = $powerShellInstance.EndInvoke($asyncResult)

    # Output the results from the script block
    foreach ($output in $scriptOutput) {
        Write-Output $output
    }

    # Close the runspace when done
    $runspace.Close()

}
