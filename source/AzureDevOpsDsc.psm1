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



[DscResource()]
class DSC_AzDevOpsProject
{

    [DscProperty()]
    [Ensure]$Ensure


    [DscProperty()]
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat


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
