<#
.SYNOPSIS
Creates a new Azure DevOps group permission.

.DESCRIPTION
The New-AzDoGroupPermission function creates a new permission set for a specified Azure DevOps group.
It formats the group name, retrieves necessary security namespace and project information,
serializes the ACLs, and sets the permissions accordingly.

.PARAMETER GroupName
Specifies the name of the group for which the permissions are being set. This parameter is mandatory.

.PARAMETER isInherited
Indicates whether the permissions are inherited. This parameter is mandatory.

.PARAMETER Permissions
Specifies a hashtable array of permissions to be applied. This parameter is optional.

.PARAMETER LookupResult
Specifies a hashtable containing lookup results. This parameter is optional.

.PARAMETER Ensure
Specifies the desired state of the permissions. This parameter is optional.

.PARAMETER Force
Forces the command to run without asking for user confirmation. This parameter is optional.

.EXAMPLE
New-AzDoGroupPermission -GroupName "ProjectName\GroupName" -isInherited $true -Permissions $permissions -LookupResult $lookupResult -Ensure Present -Force

.NOTES
This function requires the Azure DevOps PowerShell module and appropriate permissions to set group permissions.
#>
Function New-AzDoGroupPermission
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

    Write-Verbose "[New-AzDoProjectGroupPermission] Started."

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
    $Group = Get-CacheItem -Key $('[{0}]\{1}' -f $ProjectName, $GroupName) -Type 'LiveGroups'

    #
    # Serialize the ACLs

    $serializeACLParams = @{
        ReferenceACLs = $LookupResult.propertiesChanged
        DescriptorACLList = Get-CacheItem -Key $SecurityNamespace.namespaceId -Type 'LiveACLList'
        DescriptorMatchToken = ($LocalizedDataAzSerializationPatten.GroupPermission -f $Project.id, $Group.id)
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
