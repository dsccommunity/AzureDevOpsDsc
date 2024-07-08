<#
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty(Mandatory)]
    [Alias('Repository')]
    [System.String]$RepositoryName

    [DscProperty()]
    [Alias('Inherited')]
    [System.Boolean]$isInherited=$true

    [DscProperty()]
    [Alias('Permissions')]
    [Permission[]]$PermissionsList

#>
Function Get-xAzDoGitPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectName,

        [Parameter(Mandatory)]
        [string]$RepositoryName,

        [Parameter(Mandatory)]
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

    Write-Verbose "[Get-xAzDoGitPermission] Started."

    # Define the Descriptor Type and Organization Name
    $SecurityNamespace = 'Git Repositories'
    $OrganizationName = $Global:DSCAZDO_OrganizationName

    Write-Verbose "[Get-xAzDoGitPermission] Security Namespace: $SecurityNamespace"
    Write-Verbose "[Get-xAzDoGitPermission] Organization Name: $OrganizationName"

    #
    # Construct a hashtable detailing the group

    $getGroupResult = @{
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        project = $ProjectName
        repositoryName = $RepositoryName
        status = $null
    }

    Write-Verbose "[Get-xAzDoGitPermission] Group result hashtable constructed."
    Write-Verbose "[Get-xAzDoGitPermission] Performing lookup of permissions for the repository."

    # Define the ACL List
    $ACLList = [System.Collections.Generic.List[Hashtable]]::new()

    #
    # Perform a Lookup within the Cache for the Repository
    $repository = Get-CacheItem -Key $("{0}\{1}" -f $ProjectName, $RepositoryName) -Type 'LiveRepositories'

    # Test if the Repository was found
    if (-not $repository) {
        Throw "[Get-xAzDoGitPermission] Repository not found: $RepositoryName"
        return
    }

    #
    # Perform Lookup of the Permissions for the Repository

    $namespace = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'
    Write-Verbose "[Get-xAzDoGitPermission] Retrieved namespace: $($namespace.namespaceId)"

    # Add to the ACL Lookup Params
    $getGroupResult.namespace = $namespace

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecurityDescriptorId    = $namespace.namespaceId
    }

    # Get the ACL List and format the ACLS
    Write-Verbose "[Get-xAzDoGitPermission] ACL Lookup Params: $($ACLLookupParams | Out-String)"

    @{
        SecurityNamespace   = $SecurityNamespace
        OrganizationName = $OrganizationName
    } | Export-Clixml 'C:\Temp\Get-xAzDoGitPermission-params.clixml'

    $DifferenceACLs = Get-DevOpsACL @ACLLookupParams | ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName | Where-Object {
        ($_.Token.Type -eq 'GitRepository') -and ($_.Token.RepoId -eq $repository.id)
    }

    Write-Verbose "[Get-xAzDoGitPermission] ACL List retrieved and formatted."

    #
    # Convert the Permissions into an ACL Token

    $params = @{
        Permissions         = $Permissions
        SecurityNamespace   = $SecurityNamespace
        isInherited         = $isInherited
        OrganizationName    = $OrganizationName
        TokenName           = "[{0}]\{1}" -f $ProjectName, $RepositoryName
    }

    # Convert the Permissions to an ACL Token
    $ReferenceACLs = ConvertTo-ACL @params | Where-Object { $_.token.Type -ne 'GitUnknown' }

    # Compare the Reference ACLs to the Difference ACLs
    $compareResult = Test-ACLListforChanges -ReferenceACLs $ReferenceACLs -DifferenceACLs $DifferenceACLs
    $getGroupResult.propertiesChanged = $compareResult.propertiesChanged
    $getGroupResult.status = [DSCGetSummaryState]::"$($compareResult.status)"

    # Export the ACL List to a file
    $getGroupResult.ReferenceACLs = $ReferenceACLs
    $getGroupResult.DifferenceACLs = $DifferenceACLs

    # Return the Group Result
    return $getGroupResult

}

