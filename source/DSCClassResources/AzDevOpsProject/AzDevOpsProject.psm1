using module ..\..\Classes\DscResourceBase\DscResourceBase.psm1
using module ..\..\Classes\AzDevOpsApiDscResourceBase\AzDevOpsApiDscResourceBase.psm1
using module ..\..\Classes\AzDevOpsDscResourceBase\AzDevOpsDscResourceBase.psm1

$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDevOpsProject : AzDevOpsDscResourceBase
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


    [AzDevOpsProject] Get()
    {
        return [AzDevOpsProject]$($this.GetDscCurrentStateProperties())
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
