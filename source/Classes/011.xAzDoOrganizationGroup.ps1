<#
.SYNOPSIS
    This class represents an Azure DevOps organization group.

.DESCRIPTION
    The xAzDoOrganizationGroup class is a DSC resource that allows you to manage Azure DevOps organization groups.
    It provides properties to specify the group name, display name, and description.

.NOTES
    Author: Your Name
    Date:   Current Date

.LINK
    GitHub Repository: <link to the GitHub repository>

.PARAMETER GroupName
    The name of the organization group.
    This property is mandatory and serves as the key property for the resource.

.PARAMETER GroupDisplayName
    The display name of the organization group.
    This property is mandatory and serves as the key property for the resource.

.PARAMETER GroupDescription
    The description of the organization group.

.INPUTS
    None.

.OUTPUTS
    None.

.EXAMPLE
    This example shows how to create an instance of the xAzDoOrganizationGroup class:

    $organizationGroup = [xAzDoOrganizationGroup]::new()
    $organizationGroup.GroupName = "MyGroup"
    $organizationGroup.GroupDisplayName = "My Group"
    $organizationGroup.GroupDescription = "This is my group."

    $organizationGroup.Get()

#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoOrganizationGroup : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty()]
    [Alias('DisplayName')]
    [System.String]$GroupDisplayName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$GroupDescription

    [xAzDoOrganizationGroup] Get()
    {
        return [xAzDoOrganizationGroup]$($this.GetDscCurrentStateProperties())
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

        if ($null -ne $CurrentResourceObject)
        {
            $properties.Ensure = ([System.String]::IsNullOrEmpty($CurrentResourceObject.name)) ? [Ensure]::Absent : [Ensure]::Present
            $properties.GroupName = $CurrentResourceObject.name
            $properties.GroupDisplayName = $CurrentResourceObject.displayName
            $properties.GroupDescription = $CurrentResourceObject.description
        }

        Write-Verbose "[xAzDoOrganizationGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
