$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Common'
$script:azureDevOpsDscServerModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Server'
$script:azureDevOpsDscServicesModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Services'
#$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'

Import-Module -Name $script:azureDevOpsDscCommonModulePath
Import-Module -Name $script:azureDevOpsDscServerModulePath
Import-Module -Name $script:azureDevOpsDscServicesModulePath
#Import-Module -Name $script:dscResourceCommonModulePath

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
    [Ensure]$Ensure


    [DscProperty()]
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat


    [DscProperty()]
    [Alias('Id')]
    [string]$ProjectId = '*'

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [string]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [string]$ProjectDescription

    [hashtable]GetAzDevOpsObject()
    {
        $getParameters = @{
            ApiUri      = $this.ApiUri
            Pat         = $this.Pat
            ProjectId   = $(if ([string]::IsNullOrWhiteSpace($this.ProjectId)) { [guid]::NewGuid().ToString() }else{$this.ProjectId})
            ProjectName = $this.ProjectName
        }

        return Get-AzDevOpsProject @getParameters
    }

    [DSC_AzDevOpsProject] Get()
    {
        $project = $this.GetAzDevOpsObject()

        if ($null -eq $project)
        {
            return $null
        }

        return [DSC_AzDevOpsProject]@{

            # Existing properties
            Ensure = $this.Ensure
            ApiUri = $this.ApiUri
            Pat = $this.Pat

            # Updated properties (from 'Get')
            ProjectId = $project.id
            ProjectName = $project.name
            ProjectDescription = $project.description
        }

    }


    [bool] Test()
    {
        #$current = $this.Get()
        return $true
    }


    [void] Set()
    {
        #$current = $this.Get()
    }


}
