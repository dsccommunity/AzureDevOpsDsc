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
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat


    [DscProperty(Key,Mandatory)]
    [Alias('Name')]
    [string]$ProjectName

    [DscProperty()]
    [Ensure]$Ensure

    [DscProperty()]
    [Alias('Description')]
    [string]$ProjectDescription



    [DSC_AzDevOpsProject] Get()
    {
        $parameterSet = @{
            ApiUri      = $this.ApiUri
            Pat         = $this.Pat
            ProjectName = $this.ProjectName
        }

        return [DSC_AzDevOpsProject]::new() #|
                    #Add-Member -NotePropertyName 'ApiUri' -NotePropertyValue $this.ApiUri -Force -PassThru |
                    #Add-Member -NotePropertyName 'Pat' -NotePropertyValue $this.Pat -Force -PassThru |
                    #Add-Member -NotePropertyName 'ProjectName' -NotePropertyValue $this.ProjectName -Force -PassThru

    }


    [bool] Test()
    {
        return $true
    }


    [void] Set() {}


}
