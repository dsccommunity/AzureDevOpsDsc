<#
    .SYNOPSIS
        A DSC Resource for Azure DevOps that represents the 'Project' resource.

    .DESCRIPTION
        A DSC Resource for Azure DevOps that represents the 'Project' resource.

    .PARAMETER ProjectId
        The 'Id' of the Azure DevOps, 'Project' resource.

    .PARAMETER ProjectName
        The 'Name' of the Azure DevOps, 'Project' resource.

    .PARAMETER ProjectDescription
        The 'Description' of the Azure DevOps, 'Project' resource.

    .PARAMETER SourceControlType
        The 'SourceControlType' of the Azure DevOps, 'Project' resource.

        If the 'Project' resource already exists in Azure DevOps, the parameter
        `SourceControlType` cannot be used to change to another type.
#>
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
    ## [ValidateSet('Git', 'Tfvc')]
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
