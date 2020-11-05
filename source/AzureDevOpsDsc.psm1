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

enum RequiredFunction
{
    None
    New
    Set
    Remove
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

        $thisProperties = $thisType.GetProperties()
        $thisProperties | ForEach-Object {

            $PropertyName = $_.Name

            $_.GetCustomAttributes($true) |
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

        $thisProperties = $this.GetDscResourceDscPropertyNames()
        $thisProperties | ForEach-Object {

            $PropertyName = $_.Name

            $_.GetCustomAttributes($true) |
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
        $thisType = $this.GetType()
        if ($thisType -eq [DSC_AzDevOpsResource])
        {
            throw "Method 'GetResourceAlternateKeyPropertyName()' in '$($thisType.Name)' must be overidden by an inheriting class."
            return $null
        }
        return $null
    }


    hidden [string]GetResourceAlternateKey()
    {
        [string]$alternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($alternateKeyPropertyName))
        {
            return $null
        }

        return $this."$alternateKeyPropertyName"
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
        [string]$thisResourceAlternateKey = $this.GetResourceAlternateKey()
        [string]$thisResourceGetMethodName = $this.GetResourceGetMethodName()

        $getParameters = @{
            ApiUri             = $this.ApiUri
            Pat                = $this.Pat
            "$thisResourceKey" = $this."$thisResourceKey"
        }

        if (![string]::IsNullOrWhiteSpace($this."$thisResourceAlternateKey"))
        {
            $getParameters."$thisResourceAlternateKey" = $this."$thisResourceAlternateKey"
        }

        return & $thisResourceGetMethodName @getParameters
    }


    [Hashtable]GetCurrentStateProperties()
    {
        # Obtain 'CurrentStateResourceObject' and pass into overidden function of inheriting class
        return $this.GetCurrentStateProperties($this.GetCurrentStateResourceObject())
    }

    # This method must be overidden by inheriting classes
    [Hashtable]GetCurrentStateProperties([object]$ResourceObject)
    {
        $thisType = $this.GetType()
        if ($thisType -eq [DSC_AzDevOpsResource])
        {
            throw "Method 'GetCurrentState()' in '$($thisType.Name)' must be overidden by an inheriting class."
            return $null
        }
        return $null
    }

    [Hashtable]GetDesiredStateProperties()
    {
        return $this.GetResourceProperties()
    }


    [bool]IsInDesiredState(
        [hashtable]$Desired,
        [hashtable]$Current)
    {
        $thisType = $this.GetType()
        if ($thisType -eq [DSC_AzDevOpsResource])
        {
            throw "Method 'IsInDesiredState()' in '$($thisType.Name)' must be overidden by an inheriting class."
            return $null
        }
        return $null
    }

}


[DscResource()]
class DSC_AzDevOpsProject : DSC_AzDevOpsResource
{

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
        $requiredFunction = [RequiredFunction]::None
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
                    $requiredFunction = [RequiredFunction]::New
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
                    $requiredFunction = [RequiredFunction]::Set
                }
                break
            }
            'Absent' {
                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $existing -and $existing.Ensure -ne 'Absent')
                {
                    $requiredFunction = [RequiredFunction]::Remove
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
                throw "Could not obtain a valid 'RequiredFunction' value within 'DSC_AzDevOpsProject' Set() function."
            }
        }

    }

}
