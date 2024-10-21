<#
.SYNOPSIS
Removes Azure DevOps group permissions for a specified group.

.DESCRIPTION
The Remove-AzDoGroupPermission function removes permissions for a specified group in Azure DevOps.
It validates the group name, retrieves the necessary security namespace and project information,
and removes the Access Control Lists (ACLs) associated with the group if they exist.

.PARAMETER GroupName
Specifies the name of the group whose permissions are to be removed. This parameter is mandatory.

.PARAMETER isInherited
Indicates whether the permissions are inherited. This parameter is mandatory.

.PARAMETER Permissions
Specifies a hashtable array of permissions to be removed. This parameter is optional.

.PARAMETER LookupResult
Specifies a hashtable for lookup results. This parameter is optional.

.PARAMETER Ensure
Specifies the desired state of the permissions. This parameter is optional.

.PARAMETER Force
Forces the removal of permissions without prompting for confirmation. This parameter is optional.

.EXAMPLE
Remove-AzDoGroupPermission -GroupName "ProjectName\GroupName" -isInherited $true

This example removes the permissions for the specified group in the given project.

.NOTES
The function uses cached items to retrieve security namespace, project, and repository information.
It filters the ACLs related to the Git repository and removes them if they exist.
#>
Function Remove-AzDoGroupPermission
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


    Write-Verbose "[Remove-AzDoGroupPermission] Started."

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

    $SecurityNamespace  = Get-CacheItem -Key 'Identity' -Type 'SecurityNamespaces'
    $Project            = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
    $Repository         = Get-CacheItem -Key "$ProjectName\$RepositoryName" -Type 'LiveRepositories'
    $DescriptorACLList  = Get-CacheItem -Key $SecurityNamespace.namespaceId -Type 'LiveACLList'

    #
    # Filter the ACLs that pertain to the Git Repository

    $searchString = 'repoV2/{0}/{1}' -f $Project.id, $Repository.id

    # Test if the Token exists
    $Filtered = $DescriptorACLList | Where-Object { $_.token -eq $searchString }

    # If the ACLs are not null, remove them
    if ($Filtered)
    {

        $params = @{
            OrganizationName = $Global:DSCAZDO_OrganizationName
            SecurityNamespaceID = $SecurityNamespace.namespaceId
            TokenName = $searchString
        }

        # Remove the ACLs
        Remove-AzDoPermission @params

    }

}
