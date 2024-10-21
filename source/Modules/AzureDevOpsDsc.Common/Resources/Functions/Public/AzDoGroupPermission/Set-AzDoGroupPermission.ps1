<#
.SYNOPSIS
Sets Azure DevOps group permissions.

.DESCRIPTION
The Set-AzDoGroupPermission function sets permissions for a specified Azure DevOps group.
It formats the group name, retrieves necessary security namespace and project information,
serializes ACLs, and applies the permissions.

.PARAMETER GroupName
The name of the group for which permissions are being set. This parameter is mandatory.

.PARAMETER isInherited
A boolean value indicating whether the permissions are inherited. This parameter is mandatory.

.PARAMETER Permissions
A hashtable array containing the permissions to be set. This parameter is optional.

.PARAMETER LookupResult
A hashtable containing the lookup results. This parameter is optional.

.PARAMETER Ensure
Specifies whether the permissions should be ensured. This parameter is optional.

.PARAMETER Force
A switch parameter to force the operation. This parameter is optional.

.EXAMPLE
Set-AzDoGroupPermission -GroupName "ProjectName\GroupName" -isInherited $true -Permissions $permissions -LookupResult $lookupResult -Ensure Present -Force

.NOTES
This function relies on cached items for security namespace and project information.
#>

Function Set-AzDoGroupPermission
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,

        [Parameter(Mandatory = $true)]
        [bool]$isInherited,

        [Parameter()]
        [HashTable[]]$Permissions,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Write-Verbose "[Set-AzDoGroupPermission] Started."

    #
    # Format the Group Name

    # Split the Group Name
    $split = $GroupName.Split('\').Split('/')

    # Test if the Group Name is valid
    if ($split.Count -ne 2)
    {
        Write-Warning "[Get-AzDoProjectGroupPermission] Invalid Group Name: $GroupName"
        return
    }

    # Define the Project and Group Name
    $ProjectName = $split[0]
    $GroupName = $split[1]

    #
    # Security Namespace ID

    $SecurityNamespace = Get-CacheItem -Key 'Identity' -Type 'SecurityNamespaces'
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    #
    # Serialize the ACLs

    $serializeACLParams = @{
        ReferenceACLs = $LookupResult.propertiesChanged
        DescriptorACLList = Get-CacheItem -Key $SecurityNamespace.namespaceId -Type 'LiveACLList'
        DescriptorMatchToken = ($LocalizedDataAzSerializationPatten.GitRepository -f $Project.id)
    }

    $params = @{
        OrganizationName = $Global:DSCAZDO_OrganizationName
        SecurityNamespaceID = $SecurityNamespace.namespaceId
        SerializedACLs = ConvertTo-ACLHashtable @serializeACLParams
    }

    #
    # Set the Git Repository Permissions

    Set-AzDoPermission @params

}
