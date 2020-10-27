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


    [DscProperty(Mandatory)]
    [Alias('Id')]
    [string]$ProjectId

    [DscProperty(Key,Mandatory)]
    [Alias('Name')]
    [string]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [string]$ProjectDescription



    [DSC_AzDevOpsProject] Get()
    {
        $newObject = [DSC_AzDevOpsProject]::new()
        $newObject.Ensure = $this.Ensure
        $newObject.ApiUri = $this.ApiUri
        $newObject.Pat = $this.Pat
        $newObject.ProjectName = $this.ProjectName
        $newObject.ProjectDescription = $this.ProjectDescription

        return $newObject
    }


    [bool] Test()
    {
        return $true
    }


    [void] Set() {}


}
