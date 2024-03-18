using module AzureDevOpsDsc.Common

<#
.SYNOPSIS
    This class represents an Azure DevOps organization group permission.

.DESCRIPTION
    The xAzDoOrganizationGroupPermission class is used to manage Azure DevOps organization group permissions.
    It inherits from the AzDevOpsDscResourceBase class.

.PARAMETER GroupName
    Specifies the name of the Azure DevOps organization group.

.PARAMETER GroupPermission
    Specifies the permissions for the Azure DevOps organization group.

.METHODS
    Get()
        Retrieves the current state of the xAzDoOrganizationGroupPermission resource.

.HIDDEN METHODS
    GetDscResourcePropertyNamesWithNoSetSupport()
        Returns an array of property names that do not support the Set method.

    GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
        Returns a hashtable of the current state properties of the xAzDoOrganizationGroupPermission resource.

#>
class xAzDoOrganizationGroupPermission : AzDevOpsDscResourceBase
{
    [DscProperty(Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty(Mandatory)]
    [Alias('Permission')]
    [xAzDoOrganizationGroupPermission[]]$GroupPermission

    [xAzDoOrganizationGroupPermission] Get()
    {
        return [xAzDoOrganizationGroupPermission]$($this.GetDscCurrentStateProperties())
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
            $properties.GroupName = $CurrentResourceObject.name
            $properties.GroupPermission = $CurrentResourceObject.permission
        }

        return $properties
    }

}
