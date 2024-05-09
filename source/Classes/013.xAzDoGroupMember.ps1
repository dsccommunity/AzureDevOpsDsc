using module AzureDevOpsDsc.Common

<#
.SYNOPSIS
    This class represents an Azure DevOps organization group permission.

.DESCRIPTION
    The xAzDoGroupMember class is used to manage Azure DevOps organization group permissions.
    It inherits from the AzDevOpsDscResourceBase class.

.PARAMETER GroupName
    Specifies the name of the Azure DevOps organization group.

.PARAMETER GroupPermission
    Specifies the permissions for the Azure DevOps organization group.

.METHODS
    Get()
        Retrieves the current state of the xAzDoGroupMember resource.

.HIDDEN METHODS
    GetDscResourcePropertyNamesWithNoSetSupport()
        Returns an array of property names that do not support the Set method.

    GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
        Returns a hashtable of the current state properties of the xAzDoGroupMember resource.

#>
#[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoGroupMember : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty(Mandatory)]
    [Alias('Members')]
    [System.String[]]$GroupMembers

    xAzDoGroupMember()
    {
        $this.Construct()
    }

    [xAzDoGroupMember] Get()
    {
        return [xAzDoGroupMember]$($this.GetDscCurrentStateProperties())
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
        if ($null -eq $CurrentResourceObject) { return $properties }

        $properties.GroupName           = $CurrentResourceObject.GroupName
        $properties.GroupMembers        = $CurrentResourceObject.GroupMembers

        Write-Verbose "[xAzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
