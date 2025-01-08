<#
.SYNOPSIS
    This class represents an Azure DevOps project group.

.DESCRIPTION
    The AzDoProjectGroup class is a DSC resource that allows you to manage Azure DevOps project groups.

.NOTES
    Author: Michael Zanatta
    Date:  2025-01-06

.LINK
    GitHub Repository: <link to your GitHub repository>

.PARAMETER ProjectName
    The name of the Azure DevOps project associated with the project group.

.PARAMETER GroupName
    The name of the project group.

.PARAMETER GroupDescription
    The description of the project group.

.EXAMPLE
    This example shows how to create a new project group:

    $projectGroup = [AzDoProjectGroup]::new()
    $projectGroup.ProjectName = "MyProject"
    $projectGroup.GroupName = "MyGroup"
    $projectGroup.GroupDescription = "This is my project group."
    $projectGroup.Ensure = "Present"
    $projectGroup.Pat = "**********"
    $projectGroup.ApiUri = "https://dev.azure.com/MyOrganization"

    $projectGroup | Set-DscResource

.INPUTS
    None

.OUTPUTS
    None
#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDoProjectGroup : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty(Mandatory)]
    [Alias('Project')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$GroupDescription

    AzDoProjectGroup()
    {
        $this.Construct()
    }

    [AzDoProjectGroup] Get()
    {
        return [AzDoProjectGroup]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
    }

    hidden [HashTable] getDscCurrentAPIState()
    {
        # Get the current state of the resource
        $params = @{
            GroupName = $this.GroupName
            GroupDescription = $this.GroupDescription
            ProjectName = $this.ProjectName
        }

        return Get-AzDoProjectGroup @params

    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Ensure = [Ensure]::Absent
        }

        # If the resource object is null, return the properties
        if ($null -eq $CurrentResourceObject)
        {
            return $properties
        }

        $properties.GroupName           = $CurrentResourceObject.GroupName
        $properties.GroupDescription    = $CurrentResourceObject.GroupDescription
        $properties.ProjectName         = $CurrentResourceObject.ProjectName
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult
        #$properties.Reasons             = $CurrentResourceObject.LookupResult.Reasons

        Write-Verbose "[AzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
