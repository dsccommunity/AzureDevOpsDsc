<#
.SYNOPSIS
    This class represents an Azure DevOps organization group.

.DESCRIPTION
    The AzDoOrganizationGroup class is a DSC resource that allows you to manage Azure DevOps organization groups.
    It provides properties to specify the group name, display name, and description.

.NOTES
    Author: Michael Zanatta
    Date: 2025-01-06

.LINK
    GitHub Repository: <link to the GitHub repository>

.PARAMETER GroupName
    The name of the organization group.
    This property is mandatory and serves as the key property for the resource.

.PARAMETER GroupDescription
    The description of the organization group.

.INPUTS
    None.

.OUTPUTS
    None.

.EXAMPLE
    This example shows how to create an instance of the AzDoOrganizationGroup class:

    $organizationGroup = [AzDoOrganizationGroup]::new()
    $organizationGroup.GroupName = "MyGroup"
    $organizationGroup.GroupDescription = "This is my group."

    $organizationGroup.Get()

#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDoOrganizationGroup : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$GroupDescription

    AzDoOrganizationGroup()
    {
        $this.Construct()
    }

    [AzDoOrganizationGroup] Get()
    {
        return [AzDoOrganizationGroup]$($this.GetDscCurrentStateProperties())
    }

    hidden [HashTable] getDscCurrentAPIState()
    {
        # Get the current state of the resource
        $params = @{
            GroupName = $this.GroupName
            GroupDescription = $this.GroupDescription
        }

        return Get-AzDoOrganizationGroup @params

    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
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
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult
        #$properties.Reasons             = $CurrentResourceObject.LookupResult.Reasons

        Write-Verbose "[AzDoOrganizationGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }
}
