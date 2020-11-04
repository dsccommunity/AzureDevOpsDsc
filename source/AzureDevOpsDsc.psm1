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
            return $null
        }

        Write-Verbose "Get()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "

        return [DSC_AzDevOpsProject]@{

            # Existing properties
            Ensure = $this.Ensure
            ApiUri = $this.ApiUri
            Pat = $this.Pat

            # Updated properties (from 'Get')
            ProjectId = $existing.id
            ProjectName = $existing.name
            ProjectDescription = $existing.description
        }

    }


    [bool] Test()
    {
        $existing = $this.Get()

        Write-Verbose "Test()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "

        switch ($this.Ensure)
        {
            'Present' {
                # If not already present, or different to expected/desired - return $false (i.e. state is incorrect)
                if ($null -eq $existing)
                {
                    return $false
                }
                # Following comparisons are DSCResource-specific
                elseif ($existing.ProjectDescription -ne $this.ProjectDescription -or
                        $existing.SourceControlType -ne $this.SourceControlType)
                {
                    return $false
                }
                break
            }
            'Absent' {
                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $existing)
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
        $existing = $this.Get()
        $requiredFunction = [RequiredFunction]::None

        Write-Verbose "Set()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "

        switch ($this.Ensure)
        {
            'Present' {
                # If not already present, or different to expected/desired - return $false (i.e. state is incorrect)
                if ($null -eq $existing)
                {
                    $requiredFunction = [RequiredFunction]::New
                }
                elseif ($existing.ProjectDescription -ne $this.ProjectDescription -or
                        $existing.SourceControlType -ne $this.SourceControlType)
                {
                    $requiredFunction = [RequiredFunction]::Set
                }
                break
            }
            'Absent' {
                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $existing)
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
            SourceControlType  = 'Git'
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
                Start-Sleep -Seconds 5 # Need/Want to remove .... and replace with wait in the 'New-AzDevOpsProject' command
                break
            }
            'Set' {
                throw 'Need to implement "Set-AzDevOpsProject" (using PATCH)'
                Set-AzDevOpsProject @newSetParameters -Force | Out-Null
                Start-Sleep -Seconds 5 # Need/Want to remove .... and replace with wait in the 'Set-AzDevOpsProject' command
                break
            }
            default {
                throw "Could not obtain a valid 'RequiredFunction' value within 'DSC_AzDevOpsProject' Set() function."
            }
        }

    }

}
