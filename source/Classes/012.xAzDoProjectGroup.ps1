<#
.SYNOPSIS
    This class represents an Azure DevOps project group.

.DESCRIPTION
    The xAzDoProjectGroup class is a DSC resource that allows you to manage Azure DevOps project groups.

.NOTES
    Author: Your Name
    Date:   Current Date

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

    $projectGroup = [xAzDoProjectGroup]::new()
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
class xAzDoProjectGroup : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [System.String]$ProjectName

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$GroupDescription

    [xAzDoProjectGroup] Get()
    {
        return [xAzDoProjectGroup]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
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
            $properties.ProjectName = $CurrentResourceObject.ProjectName
            $properties.GroupName = $CurrentResourceObject.name
            $properties.GroupDescription = $CurrentResourceObject.description

        }

        return $properties
    }

}
