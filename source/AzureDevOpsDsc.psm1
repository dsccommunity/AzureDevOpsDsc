using module .\Classes\DscResourceBase\DscResourceBase.psm1
using module .\Classes\AzDevOpsApiDscResourceBase\AzDevOpsApiDscResourceBase.psm1
using module .\Classes\AzDevOpsDscResourceBase\AzDevOpsDscResourceBase.psm1

$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
#$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DscResource.Common'

Import-Module -Name $script:azureDevOpsDscCommonModulePath
#Import-Module -Name $script:dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


[DscResource()]
class DSC_AzDevOpsProject : AzDevOpsDscResourceBase
{

    [DscProperty()]
    [Alias('Id')]
    [System.String]$ProjectId

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$ProjectDescription

    [DscProperty()]
    [System.String]$SourceControlType


    [DSC_AzDevOpsProject] Get()
    {
        return [DSC_AzDevOpsProject]$($this.GetDscCurrentStateProperties())
    }

    [System.Boolean] Test() # Note: Overides identical method in base class but removes linting errors
    {
        return $this.TestDesiredState()
    }

    [void] Set() # Note: Overides identical method in base class but removes linting errors
    {
        $this.SetToDesiredState()
    }


    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @('SourceControlType')
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Pat = $this.Pat
            ApiUri = $this.ApiUri
            Ensure = [Ensure]::Absent
        }

        if ($null -ne $CurrentResourceObject)
        {
            if (![System.String]::IsNullOrWhiteSpace($CurrentResourceObject.id))
            {
                $properties.Ensure = [Ensure]::Present
            }
            $properties.ProjectId = $CurrentResourceObject.id
            $properties.ProjectName = $CurrentResourceObject.name
            $properties.ProjectDescription = $CurrentResourceObject.description
            $properties.SourceControlType = $CurrentResourceObject.capabilities.versioncontrol.sourceControlType
        }

        return $properties
    }

}
