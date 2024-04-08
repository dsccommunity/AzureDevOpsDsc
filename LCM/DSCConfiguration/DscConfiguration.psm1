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

    $ResourcesWithoutDependsOn, $ResourcesWithDependsOn = $PipelineResources.Where({ $null -eq $_.DependsOn }, 'Split')

    #
    # Format the DependsOn Property by ensuring the Resource parent is before the child.

    $TaskList = [System.Collections.ArrayList]::New()

    #
    # Enumerate the Resources with DependsOn Property

    ForEach ($ResourceObject in $ResourcesWithDependsOn) {

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
            throw "Resource [$($_.Type)/$($_.Name)] DependsOn Resource cannot be the same Resource."
        }

        # Enumerate the DependsOn Property and locate the Resource within ResourceConfiguration.
        # Order the Resources by the index position of the Resource within ResourceConfiguration.
        # We only need the lowest index number since the resource can be inserted before the Resource.

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

            if ($ResourceTopIndex -eq 0) { $null = $TaskList.Insert(0, $ResourceObject) }
            else { $null = $TaskList.Insert($ResourceTopIndex - 1, $ResourceObject) }

        }
    }

    #
    # Add ResourcesWithoutDependsOn to the top of the task list.
    $ResourcesWithoutDependsOn | ForEach-Object {
        $null = $TaskList.Insert(0, $_)
    }

    $TaskList

}

function Invoke-DscConfiguration {
    param (
        [string] $FilePath,
        [ValidateSet("Test", "Set")]
        [string] $Mode = "Test"
    )

    $fileExtension = [System.IO.Path]::GetExtension($FilePath)

    if ($fileExtension -eq ".yaml" -or $fileExtension -eq ".yml") {
        $pipeline = get-content $FilePath | ConvertFrom-Yaml
    }
    elseif ($fileExtension -eq ".json") {
        $pipeline = get-content $FilePath | ConvertFrom-Json -AsHashtable
    }

    $parameters.Clear()
    $variables.Clear()
    $references.Clear()

    $defaultValues = GetDefaultValues -Source $pipeline.parameters
    SetVariables -Source $pipeline.variables -Target $variables
    SetVariables -Source $defaultValues -Target $parameters

    # Format the Depends On
    $tasks = Sort-DependsOn -PipelineResources $pipeline.resources

    # Execute Tasks
    foreach ($task in $tasks) {

        Write-Host "Resource [$($task.type)/$($task.name)]"

        $condition = [scriptblock]::New($task.condition)
        if ($null -ne $task.condition -and $condition.Invoke() -eq $false) {
            Write-Host "skipping" -ForegroundColor Cyan
            continue
        }

        $module = $task.type.Split("/")[0]
        $resourceType = $task.type.Split("/")[1]

        # Install the module if needed
        $installedModule = Get-InstalledModule -Name $module -ErrorAction SilentlyContinue
        if ($null -eq $installedModule) {
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
            Install-Module -Name $module -Confirm:$false -AcceptLicense -Repository PSGallery
        }

        # Expand variables in the input values
        $Property = @{}
        foreach ($key in $task.properties.Keys) {
            $inputValue = $ExecutionContext.InvokeCommand.ExpandString($task.properties[$key])

            $Property.Add($key, $inputValue)
        }

        $resourceParameters = @{
            Name = $resourceType
            ModuleName = $module
            Method = "Test"
            Property = $Property
        }

        # Execute Test for task
        $result = Invoke-DscResource @resourceParameters

        # Execute Set for task
        if ($result.InDesiredState) {
            Write-Host "ok" -ForegroundColor Green
        }
        elseif ($Mode -eq "Set") {
            $resourceParameters.Method = "Set"
            try {
                Invoke-DscResource @resourceParameters
                Write-Host "changed" -ForegroundColor Yellow
            }
            catch {
                Write-Host "failed" -ForegroundColor Red
            }
        }
        else {
            Write-Host "change needed" -ForegroundColor Yellow
        }

        # Remove all Properties except required properties or else the Get method gets mad
        $resource = Get-DscResource -Module $module -Name $resourceType
        $mandatoryProperties = @()
        $resource.Properties | Where-Object { $_.IsMandatory } | ForEach-Object { $mandatoryProperties += $_.Name }

        $getProperties = @{}
        foreach ($key in $resourceParameters.Property.Keys) {
            if ($mandatoryProperties.Contains($key)) {
                $getProperties.Add($key, $resourceParameters.Property[$key])
            }
        }

        $resourceParameters.Method = "Get"
        $resourceParameters.Property = $getProperties
        $output_var = Invoke-DscResource @resourceParameters
        $references.Add($task.name, $output_var)

    }
}


