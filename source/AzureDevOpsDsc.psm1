$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
$script:azureDevOpsDscServerModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Server'
$script:azureDevOpsDscServicesModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Services'
#$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DscResource.Common'

Import-Module -Name $script:azureDevOpsDscCommonModulePath
Import-Module -Name $script:azureDevOpsDscServerModulePath
Import-Module -Name $script:azureDevOpsDscServicesModulePath
#Import-Module -Name $script:dscResourceCommonModulePath
#
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


enum Ensure
{
    Present
    Absent
}

enum RequiredAction
{
    None
    New
    Set
    Remove
    Error
}



class DSC_AzDevOpsResource
{
    [DscProperty()]
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat

    [DscProperty()]
    [Ensure]$Ensure


    # Non-DSC properties for use in operations/comparisons


    # Hidden properties
    hidden [string]$ResourceKey
    hidden [string]$ResourceKeyPropertyName
    hidden [string]$ResourceName = $this.GetResourceName()
    hidden [hashtable]$ResourceProperties = $this.GetResourceProperties()


    # Constructor(s)
    DSC_AzDevOpsResource(){}


    # DSC-specific methods

    hidden [string[]]GetDscResourceDscPropertyNames()
    {
        [string[]]$thisDscPropertyNames = @()

        [Type]$thisType = $this.GetType()
        [System.Reflection.PropertyInfo[]]$thisProperties = $thisType.GetProperties()

        $thisProperties | ForEach-Object {
            [System.Reflection.PropertyInfo]$propertyInfo = $_
            $PropertyName = $_.Name

            $propertyInfo.GetCustomAttributes($true) |
            ForEach-Object {

                if ($_.TypeId.Name -eq 'DscPropertyAttribute')
                {
                    $thisDscPropertyNames += $PropertyName
                }
            }
        }

        return $thisDscPropertyNames
    }

    hidden [string]GetDscResourceDscKeyPropertyName()
    {
        [string[]]$thisDscKeyPropertyNames = @()

        [Type]$thisType = $this.GetType()
        [System.Reflection.PropertyInfo[]]$thisProperties = $thisType.GetProperties()

        $thisProperties | ForEach-Object {
            Write-Verbose $_.Name
            [System.Reflection.PropertyInfo]$propertyInfo = $_
            $PropertyName = $_.Name

            $propertyInfo.GetCustomAttributes($true) |
            ForEach-Object {

                if ($_.TypeId.Name -eq 'DscPropertyAttribute' -and
                    $_.Key -eq $true)
                {
                    $thisDscKeyPropertyNames += $PropertyName
                }
            }
        }

        if ($null -eq $thisDscKeyPropertyNames -or $thisDscKeyPropertyNames.Count -eq 0)
        {
            throw "Could not obtain a 'DscResourceDscKey' property for type '$($this.GetType().Name)'."
        }
        elseif ($thisDscKeyPropertyNames.Count -gt 1)
        {
            throw "Obtained more than 1 property for type '$($this.GetType().Name)' that was marked as a 'Key'. There must only be 1 property on the class set as the 'Key' for DSC."
        }

        return $thisDscKeyPropertyNames[0]
    }




    # Non DSC-specific methods

    hidden [string]GetResourceName()
    {
        # Assumes a naming convention is followed between the DSC
        # resource name and the name of the resource within the API
        return $this.GetType().ToString().Replace('DSC_AzDevOps','')
    }


    hidden [string]GetResourceKeyPropertyName()
    {
        # Uses the same value as the 'DscResourceDscKeyPropertyName'
        return $this.GetDscResourceDscKeyPropertyName()
    }


    hidden [string]GetResourceKey()
    {
        [string]$keyPropertyName = $this.GetResourceKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($keyPropertyName))
        {
            return $null
        }

        return $this."$keyPropertyName"
    }


    # This method must be overidden by inheriting classes
    hidden [string]GetResourceAlternateKeyPropertyName()
    {
        return "$($this.GetResourceName())Id"
    }


    hidden [string]GetResourceAlternateKey()
    {
        return $this."$($this.GetResourceAlternateKeyPropertyName())"
    }


    hidden [Hashtable]GetResourceProperties()
    {
        [PSObject]$thisObject = $this
        [Hashtable]$thisProperties = @{}

        $thisObject.PSObject.Properties | ForEach-Object {
            $thisProperties[$_.Name] = $_.Value
        }

        return $thisProperties
    }


    hidden [string]GetResourceGetMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Get-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceSetMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Set-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceRemoveMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Remove-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceTestMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Test-AzDevOps$thisResourceName"
    }


    hidden [object]GetCurrentStateResourceObject()
    {
        [string]$thisResourceKey = $this.GetResourceKey()
        [string]$thisResourceKeyPropertyName = $this.GetResourceKeyPropertyName()
        [string]$thisResourceAlternateKey = $this.GetResourceAlternateKey()
        [string]$thisResourceAlternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()
        [string]$thisResourceGetMethodName = $this.GetResourceGetMethodName()

        $getParameters = @{
            ApiUri                         = $this.ApiUri
            Pat                            = $this.Pat
            "$thisResourceKeyPropertyName" = $thisResourceKey
        }

        if (![string]::IsNullOrWhiteSpace($thisResourceAlternateKey))
        {
            $getParameters."$thisResourceAlternateKeyPropertyName" = $thisResourceAlternateKey
        }

        Write-Verbose "Calling '$thisResourceGetMethodName'..."

        $currentStateResourceObject = $(& $thisResourceGetMethodName @getParameters)

        if ($null -eq $currentStateResourceObject)
        {
            return New-Object -TypeName 'PSObject' -Property @{
                Ensure = [Ensure]::Absent
            }
        }

        return $currentStateResourceObject
    }


    hidden [Hashtable]GetCurrentStateProperties()
    {
        # Obtain 'CurrentStateResourceObject' and pass into overidden function of inheriting class
        return $this.GetCurrentStateProperties($this.GetCurrentStateResourceObject())
    }

    # This method must be overidden by inheriting classes
    hidden [Hashtable]GetCurrentStateProperties([object]$CurrentResourceObject)
    {
        $thisType = $this.GetType()
        if ($thisType -eq [DSC_AzDevOpsResource])
        {
            throw "Method 'GetCurrentState()' in '$($thisType.Name)' must be overidden by an inheriting class."
            return $null
        }
        return $null
    }


    hidden [Ensure]GetEnsure([object]$ResourceObject)
    {
        [string]$thisResourceKeyPropertyName = $this.GetResourceKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($ResourceObject."$thisResourceKeyPropertyName"))
        {
            return [Ensure]::Absent
        }
        return [Ensure]::Present
    }

    hidden [Hashtable]GetDesiredStateProperties()
    {
        return $this.GetResourceProperties()
    }


    hidden [RequiredAction]GetRequiredAction()
    {
        [hashtable]$currentProperties = $this.GetCurrentStateProperties()
        [hashtable]$desiredProperties = $this.GetDesiredStateProperties()

        [string[]]$propertyNamesUnsupportedForSet = @()
        [string[]]$propertyNamesToCompare = $this.GetDscResourceDscPropertyNames()


        # Update 'AlternateKey' property:
        # Set $desiredProperties."$alternateKeyPropertyName" to $currentProperties."$alternateKeyPropertyName" if it's desired
        # value is blank/null but it's current/existing value is known (and can be recovered from $currentProperties).
        #
        # This ensures that alternate keys (typically ResourceIds) not provided in the DSC configuration do not flag differences
        [string]$alternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()
        if ([string]::IsNullOrWhiteSpace($desiredProperties."$alternateKeyPropertyName") -and
            ![string]::IsNullOrWhiteSpace($currentProperties."$alternateKeyPropertyName"))
        {
            $desiredProperties."$alternateKeyPropertyName" = $currentProperties."$alternateKeyPropertyName"
        }


        # Perform logic with 'Ensure' (to determine whether resource should be created or dropped (or updated, if already 'Present' but property values differ)
        switch ($desiredProperties.Ensure)
        {
            'Present' {

                # If not already present, or different to expected/desired - return 'New' (i.e. Resource needs creating)
                if ($null -eq $currentProperties -or $currentProperties.Ensure -ne 'Present')
                {
                    return [RequiredAction]::New
                    break
                }

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a 'New' resource)
                if ($propertyNamesUnsupportedForSet.Count -gt 0)
                {
                    $propertyNamesUnsupportedForSet | ForEach-Object {
                        if ($currentProperties."$_" -ne $desiredProperties."$_")
                        {
                            throw "The '$($this.GetType().Name)', DSC resource does not support changes for/to the '$_' property."
                            return [RequiredAction]::Error
                            break
                        }
                    }
                }

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a 'New' resource)
                if ($propertyNamesToCompare.Count -gt 0)
                {
                    $propertyNamesToCompare | ForEach-Object {
                        if ($currentProperties."$_" -ne $desiredProperties."$_")
                        {
                            return [RequiredAction]::Set
                            break
                        }
                    }
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return [RequiredAction]::None
                break
            }
            'Absent' {
                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $currentProperties -and $currentProperties.Ensure -ne 'Absent')
                {
                    return [RequiredAction]::Remove
                    break
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return [RequiredAction]::None
                break
            }
            default {
                throw "Could not obtain a valid 'Ensure' value within 'DSC_AzDevOpsProject' Test() function. Value was '$($desiredProperties.Ensure)'."
                return [RequiredAction]::Error
            }
        }

        return [RequiredAction]::Error

    }


    hidden [bool]IsInDesiredState()
    {
        if ($this.GetRequiredAction() -eq [RequiredAction]::None)
        {
            return $true
        }

        return $false
    }


    [bool] TestNew()
    {
        return $this.IsInDesiredState()
    }

}


[DscResource()]
class DSC_AzDevOpsProject : DSC_AzDevOpsResource
{

    [Hashtable]GetCurrentStateProperties([object]$CurrentResourceObject)
    {
        $properties = @{
            Pat = $this.Pat
            ApiUri = $this.ApiUri

            Ensure = $($this.GetEnsure($CurrentResourceObject))
        }

        if ($null -ne $CurrentResourceObject)
        {
            $properties.ProductId = $CurrentResourceObject['id']
            $properties.ProductName = $CurrentResourceObject['name']
            $properties.Description = $CurrentResourceObject['description']
        }

        return $properties
    }



    [DscProperty()] # Note: Do want to be able to pass this back populated so not set as 'NotConfigurable'
    [Alias('Id')]
    [string]$ProjectId

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [string]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [string]$ProjectDescription

    [DscProperty()]
    [string]$SourceControlType


    [PSCustomObject]GetAzDevOpsResource()
    {
        $getParameters = @{
            ApiUri             = $this.ApiUri
            Pat                = $this.Pat

            ProjectName        = $this.ProjectName
        }

        if (![string]::IsNullOrWhiteSpace($this.ProjectId))
        {
            $getParameters.ProjectId = $this.ProjectId
        }

        Write-Verbose "GetAzDevOpsResource()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "

        return Get-AzDevOpsProject @getParameters
    }


    [DSC_AzDevOpsProject] Get()
    {
        $existing = $this.GetAzDevOpsResource()

        if ($null -eq $existing)
        {
            return [DSC_AzDevOpsProject]@{

                # Existing properties
                ApiUri = $this.ApiUri
                Pat = $this.Pat
                ProjectName = $this.ProjectName

                # Updated properties (from 'Get')
                Ensure = 'Absent'
            }
        }

        Write-Verbose "Get()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "this.SourceControlType      : $($this.SourceControlType) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "
        Write-Verbose "existing.SourceControlType  : $($existing.SourceControlType) "

        return [DSC_AzDevOpsProject]@{

            # Existing properties
            ApiUri = $this.ApiUri
            Pat = $this.Pat


            # Updated properties (from 'Get')
            Ensure = 'Present'
            ProjectId = $existing.id
            ProjectName = $existing.name
            ProjectDescription = $existing.description
            SourceControlType = $existing.capabilities.versioncontrol.sourceControlType
        }

    }



    [bool] Test()
    {
        Write-Verbose "Test(): Calling 'GetCurrentStateProperties'..."
        $current = $this.GetCurrentStateProperties()
        Write-Verbose "Test(): Successfully called 'GetCurrentStateProperties'."

        Write-Verbose "Test(): CurrentStateProperties are..."
        Write-Verbose $($current | ConvertTo-Json)
        Write-Verbose "Test(): "


        Write-Verbose "Test(): Calling 'GetDesiredStateProperties'..."
        $desired = $this.GetDesiredStateProperties()
        Write-Verbose "Test(): Successfully called 'GetDesiredStateProperties'."

        Write-Verbose "Test(): DesiredStateProperties are..."
        Write-Verbose $($desired | ConvertTo-Json)
        Write-Verbose "Test(): "


        $existing = $this.Get()
        # Note: $this is effectively 'desired' values

        Write-Verbose "Test()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "this.SourceControlType      : $($this.SourceControlType) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "
        Write-Verbose "existing.SourceControlType  : $($existing.SourceControlType) "

        # Set $this.ProjectId to $existing.ProjectId if it's known and can be recovered from existing resource
        if ([string]::IsNullOrWhiteSpace($this.ProjectId) -and ![string]::IsNullOrWhiteSpace($existing.ProjectId))
        {
            $this.ProjectId = $existing.ProjectId
            Write-Verbose "this.ProjectId              : $($this.ProjectId) (Since updated)"
        }

        switch ($this.Ensure)
        {
            'Present' {
                # If not already present, or different to expected/desired - return $false (i.e. state is incorrect)
                if ($null -eq $existing -or $existing.Ensure -eq 'Absent')
                {
                    return $false
                }
                # Following comparisons are DSCResource-specific but UNSUPPORTED
                elseif ($existing.SourceControlType -ne $this.SourceControlType)
                {
                    throw "This DSCResource does not support changes to the following properties: SourceControlType"
                }
                # Following comparisons are DSCResource-specific and supported
                elseif ($existing.ProjectName -ne $this.ProjectName -or
                        $existing.ProjectDescription -ne $this.ProjectDescription)
                {
                    return $false
                }
                break
            }
            'Absent' {
                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $existing -and $existing.Ensure -ne 'Absent')
                {
                    return $false
                }
                break
            }
            default
            {
                throw "Could not obtain a valid 'Ensure' value within 'DSC_AzDevOpsProject' Test() function. Value was '$($this.Ensure)'."
            }
        }

        # State is already as desired - return $true
        return $true

    }


    [void] Set()
    {
        $requiredFunction = [RequiredAction]::None
        $existing = $this.Get()

        Write-Verbose "Set()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "

        # Set $this.ProjectId to $existing.ProjectId if it's known and can be recovered from existing resource
        if ([string]::IsNullOrWhiteSpace($this.ProjectId) -and ![string]::IsNullOrWhiteSpace($existing.ProjectId))
        {
            $this.ProjectId = $existing.ProjectId
            Write-Verbose "this.ProjectId              : $($this.ProjectId) (Since updated)"
        }


        switch ($this.Ensure)
        {
            'Present' {
                # If not already present, or different to expected/desired - return $false (i.e. state is incorrect)
                if ($null -eq $existing -or $existing.Ensure -ne 'Present')
                {
                    $requiredFunction = [RequiredAction]::New
                }
                # Following comparisons are DSCResource-specific but UNSUPPORTED
                elseif ($existing.SourceControlType -ne $this.SourceControlType)
                {
                    throw "This DSCResource does not support changes to the following properties: SourceControlType"
                }
                # Following comparisons are DSCResource-specific and supported
                elseif ($existing.ProjectName -ne $this.ProjectName -or
                        $existing.ProjectDescription -ne $this.ProjectDescription)
                {
                    $requiredFunction = [RequiredAction]::Set
                }
                break
            }
            'Absent' {
                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $existing -and $existing.Ensure -ne 'Absent')
                {
                    $requiredFunction = [RequiredAction]::Remove
                }
                break
            }
            default {
                throw "Could not obtain a valid 'Ensure' value within 'DSC_AzDevOpsProject' Test() function. Value was '$($this.Ensure)'."
            }
        }


        $newSetParameters = @{
            ApiUri             = $this.ApiUri
            Pat                = $this.Pat

            ProjectName        = $this.ProjectName
            ProjectDescription = $this.ProjectDescription

            SourceControlType  = $this.SourceControlType
        }

        if (![string]::IsNullOrWhiteSpace($this.ProjectId))
        {
            $newSetParameters.ProjectId = $this.ProjectId
        }


        switch ($requiredFunction)
        {
            'None' {
                break
            }
            'New' {
                New-AzDevOpsProject @newSetParameters -Force | Out-Null
                break
            }
            'Set' {
                # Remove any not supported
                $newSetParameters.Remove('SourceControlType')


                Set-AzDevOpsProject @newSetParameters -Force | Out-Null
                break
            }
            'Remove' {
                $removeParameters = @{
                    ApiUri             = $newSetParameters.ApiUri
                    Pat                = $newSetParameters.Pat

                    ProjectId          = $newSetParameters.ProjectId
                }

                Remove-AzDevOpsProject @removeParameters -Force | Out-Null
                break
            }
            default {
                throw "Could not obtain a valid 'RequiredAction' value within 'DSC_AzDevOpsProject' Set() function."
            }
        }

    }

}
