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


[DscResource()]
class DSC_AzDevOpsProject
{

    [DscProperty()]
    [string]$Ensure


    [DscProperty()]
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat


    [DscProperty()]
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

        return Get-AzDevOpsProject @getParameters
    }


    [DSC_AzDevOpsProject] Get()
    {
        $existing = $this.GetAzDevOpsResource()

        if ($null -eq $existing)
        {
            return $null
        }

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

        if ($existing.ProjectDescription -ne $this.ProjectDescription -or
            $existing.SourceControlType -ne $this.SourceControlType)
        {
            return $false
        }

        return $true
    }


    [void] Set()
    {
        $existing = $this.Get()


        $setParameters = @{
            ApiUri             = $this.ApiUri
            Pat                = $this.Pat

            ProjectName        = $this.ProjectName
            ProjectDescription = $this.ProjectDescription
            SourceControlType  = 'Git'
        }

        if (![string]::IsNullOrWhiteSpace($this.ProjectId))
        {
            $setParameters.ProjectId = $this.ProjectId
        }


        if ($null -eq $existing)
        {
            New-AzDevOpsProject @setParameters -Force | Out-Null
        }
        else
        {
            throw 'Need to implement "Set-AzDevOpsProject" (using PATCH)'
            Set-AzDevOpsProject @setParameters -Force | Out-Null
        }


    }


}
