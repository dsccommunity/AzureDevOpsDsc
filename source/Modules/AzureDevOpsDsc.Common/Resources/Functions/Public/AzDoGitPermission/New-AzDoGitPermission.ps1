<#
.SYNOPSIS
Creates new Git repository permissions in Azure DevOps.

.DESCRIPTION
The New-AzDoGitPermission function sets up new permissions for a specified Git repository within a given project in Azure DevOps. It uses cached security namespace and project information to serialize ACLs and apply the permissions.

.PARAMETER ProjectName
The name of the Azure DevOps project.

.PARAMETER RepositoryName
The name of the Git repository within the Azure DevOps project.

.PARAMETER isInherited
Indicates whether the permissions are inherited.

.PARAMETER Permissions
A hashtable array of permissions to be applied.

.PARAMETER LookupResult
A hashtable containing the lookup result properties.

.PARAMETER Ensure
Specifies whether to ensure the permissions are set.

.PARAMETER Force
A switch parameter to force the operation.

.EXAMPLE
New-AzDoGitPermission -ProjectName "MyProject" -RepositoryName "MyRepo" -isInherited $true -Permissions $permissions -LookupResult $lookupResult -Ensure "Present" -Force

.NOTES
This function relies on cached items for security namespace and project information. Ensure that the cache is populated before calling this function.
#>
Function New-AzDoGitPermission
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,

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

    Write-Verbose "[New-AzDoGitPermission] Started."

    #
    # Security Namespace ID

    $SecurityNamespace = Get-CacheItem -Key 'Git Repositories' -Type 'SecurityNamespaces'
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    if (($null -eq $SecurityNamespace) -or ($null -eq $Project))
    {
        Write-Warning "[New-AzDoGitPermission] Security Namespace or Project not found."
        return
    }

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
