using module AzureDevOpsDsc.Common

<#
.SYNOPSIS
This class represents an Azure DevOps Git permission resource.

.DESCRIPTION
The xAzDoGitPermission class is used to manage Git repository permissions in Azure DevOps.

.NOTES
Author: Your Name
Date:   Current Date

.EXAMPLE
Example usage of the xAzDoGitPermission class:

$gitPermission = [xAzDoGitPermission]::new()
$gitPermission.ProjectName = "MyProject"
$gitPermission.GitRepositoryName = "MyRepository"
$gitPermission.Permission = @("Read", "Contribute")

$gitPermission.Get()

.LINK
Azure DevOps DSC Resource Kit: https://github.com/Azure/AzureDevOpsDsc
#>
[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoGitPermission : AzDevOpsDscResourceBase
{
    [DscProperty(Mandatory)]
    [Alias('ProjectName')]
    [System.String]$ProjectName

    [DscProperty(Mandatory)]
    [Alias('Name')]
    [System.String]$GitRepositoryName

    [DscProperty(Mandatory)]
    [AzDoGitRepositoryPermission[]]$Permission

    [xAzDoGitPermission] Get()
    {
        return [xAzDoGitPermission]$($this.GetDscCurrentStateProperties())
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
