$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Common'
$script:azureDevOpsDscServerModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Server'
$script:azureDevOpsDscServicesModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Services'
$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'

Import-Module -Name $script:azureDevOpsDscCommonModulePath
Import-Module -Name $script:azureDevOpsDscServerModulePath
Import-Module -Name $script:azureDevOpsDscServicesModulePath
Import-Module -Name $script:dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


enum Ensure
{
  Present
  Absent
}


[DscResource('AzDevOpsProject')]
class DSC_AzDevOpsProject
{

    [DscProperty(Key,Mandatory)]
    [Alias('Name')]
    [string]$ProjectName

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [Alias('Description')]
    [string]$ProjectDescription


    [DSC_AzDevOpsProject] Get()
    {
        return this
    }


    [bool] Test()
    {
        return $true
    }


    [void] Set() {}


}
