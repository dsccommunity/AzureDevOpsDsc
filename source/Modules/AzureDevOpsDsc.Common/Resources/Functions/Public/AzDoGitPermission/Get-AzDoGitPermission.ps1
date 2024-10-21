<#
.SYNOPSIS
Retrieves the Git repository permissions for a specified Azure DevOps project and repository.

.DESCRIPTION
The Get-AzDoGitPermission function retrieves the Git repository permissions for a specified Azure DevOps project and repository.
It performs a lookup within the cache for the repository and retrieves the Access Control List (ACL) for the repository.
The function then compares the retrieved ACLs with the provided permissions and returns the result.

.PARAMETER ProjectName
The name of the Azure DevOps project.

.PARAMETER RepositoryName
The name of the Git repository within the Azure DevOps project.

.PARAMETER isInherited
A boolean value indicating whether the permissions are inherited.

.PARAMETER Permissions
An optional hashtable array of permissions to compare against the retrieved ACLs.

.PARAMETER LookupResult
An optional hashtable to store the lookup result.

.PARAMETER Ensure
An optional parameter to specify the desired state of the permissions.

.PARAMETER Force
A switch parameter to force the operation.

.EXAMPLE
Get-AzDoGitPermission -ProjectName "MyProject" -RepositoryName "MyRepo" -isInherited $true

This example retrieves the Git repository permissions for the "MyRepo" repository in the "MyProject" Azure DevOps project,
considering inherited permissions.

.NOTES
The function relies on cached items for the repository and security namespace.
It uses helper functions like Get-CacheItem, Get-DevOpsACL, ConvertTo-FormattedACL, ConvertTo-ACL, and Test-ACLListforChanges.

#>

Function Get-AzDoGitPermission
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
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

    Write-Verbose "[Get-AzDoGitPermission] Started."

    # Define the Descriptor Type and Organization Name
    $SecurityNamespace = 'Git Repositories'
    $OrganizationName = $Global:DSCAZDO_OrganizationName

    Write-Verbose "[Get-AzDoGitPermission] Security Namespace: $SecurityNamespace"
    Write-Verbose "[Get-AzDoGitPermission] Organization Name: $OrganizationName"

    #
    # Construct a hashtable detailing the group

    $getGroupResult = @{
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        project = $ProjectName
        repositoryName = $RepositoryName
        status = $null
        reason = $null
    }

    Write-Verbose "[Get-AzDoGitPermission] Group result hashtable constructed."
    Write-Verbose "[Get-AzDoGitPermission] Performing lookup of permissions for the repository."

    # Define the ACL List
    $ACLList = [System.Collections.Generic.List[Hashtable]]::new()

    #
    # Perform a Lookup within the Cache for the Repository
    $repository = Get-CacheItem -Key $('{0}\{1}' -f $ProjectName, $RepositoryName) -Type 'LiveRepositories'

    # Test if the Repository was found
    if (-not $repository)
    {
        Write-Warning "[Get-AzDoGitPermission] Repository not found: $RepositoryName"
        $getGroupResult.status = [DSCGetSummaryState]::NotFound
        return $getGroupResult
    }

    #
    # Perform Lookup of the Permissions for the Repository

    $namespace = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'
    Write-Verbose "[Get-AzDoGitPermission] Retrieved namespace: $($namespace.namespaceId)"

    # Add to the ACL Lookup Params
    $getGroupResult.namespace = $namespace

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecurityDescriptorId    = $namespace.namespaceId
    }

    # Get the ACL List and format the ACLS
    Write-Verbose "[Get-AzDoGitPermission] ACL Lookup Params: $($ACLLookupParams | Out-String)"

    # Get the ACLs for the Repository
    $DevOpsACLs = Get-DevOpsACL @ACLLookupParams

    # Test if the ACLs were found
    if ($DevOpsACLs -eq $null)
    {
        Write-Warning "[Get-AzDoGitPermission] No ACLs found for the repository."
        $getGroupResult.status = [DSCGetSummaryState]::NotFound
        return $getGroupResult
    }

    # Convert the ACLs to a formatted ACL
    $DifferenceACLs = $DevOpsACLs | ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName

    # Test if the ACLs were found
    if ($DifferenceACLs -eq $null)
    {
        Write-Warning "[Get-AzDoGitPermission] No ACLs found for the repository."
        $getGroupResult.status = [DSCGetSummaryState]::NotFound
        return $getGroupResult
    }

    $DifferenceACLs = $DifferenceACLs | Where-Object {
        ($_.Token.Type -eq 'GitRepository') -and ($_.Token.RepoId -eq $repository.id)
    }

    Write-Verbose "[Get-AzDoGitPermission] ACL List retrieved and formatted."

    #
    # Convert the Permissions into an ACL Token

    $params = @{
        Permissions         = $Permissions
        SecurityNamespace   = $SecurityNamespace
        isInherited         = $isInherited
        OrganizationName    = $OrganizationName
        TokenName           = '[{0}]\{1}' -f $ProjectName, $RepositoryName
    }

    # Convert the Permissions to an ACL Token
    $ReferenceACLs = ConvertTo-ACL @params | Where-Object { $_.token.Type -ne 'GitUnknown' }

    # Compare the Reference ACLs to the Difference ACLs
    $compareResult = Test-ACLListforChanges -ReferenceACLs $ReferenceACLs -DifferenceACLs $DifferenceACLs
    $getGroupResult.propertiesChanged = $compareResult.propertiesChanged
    $getGroupResult.status = [DSCGetSummaryState]::"$($compareResult.status)"
    $getGroupResult.reason = $compareResult.reason

    Write-Verbose "[Get-AzDoGitPermission] ACL Token converted."
    Write-Verbose "[Get-AzDoGitPermission] ACL Token Comparison Result: $($getGroupResult.status)"

    # Export the ACL List to a file
    $getGroupResult.ReferenceACLs = $ReferenceACLs
    $getGroupResult.DifferenceACLs = $DifferenceACLs

    # Write
    Write-Verbose "[Get-AzDoGitPermission] Result Status: $($getGroupResult.status)"
    Write-Verbose "[Get-AzDoGitPermission] Returning Group Result."

    # Return the Group Result
    return $getGroupResult

}

