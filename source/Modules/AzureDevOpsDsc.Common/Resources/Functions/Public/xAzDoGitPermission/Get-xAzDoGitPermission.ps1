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
        #Reasons = $()
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        aclList = $null
        permissions = $null
        status = $null
        project = $project
        repositoryName = $RepositoryName
    }

    Write-Verbose "[Get-xAzDoGitPermission] Group result hashtable constructed."
    Write-Verbose "[Get-xAzDoGitPermission] Performing lookup of permissions for the repository."

    # Define the ACL List
    $ACLList = [System.Collections.Generic.List[Hashtable]]::new()


    #
    # Perform Lookup of the Permissions for the Repository

    $namespace = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'
    Write-Verbose "[Get-xAzDoGitPermission] Retrieved namespace: $($namespace.namespaceId)"

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecruityDescriptorId    = $namespace.namespaceId
    }

    Write-Verbose "[Get-xAzDoGitPermission] ACL Lookup Params: $($ACLLookupParams | Out-String)"

    # Get the ACL List and format the ACLS
    $ReferenceACLs = Get-DevOpsACL @ACLLookupParams | Format-ACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName

    Write-Verbose "[Get-xAzDoGitPermission] ACL List retrieved and formatted."
    Write-Verbose "[Get-xAzDoGitPermission] ACL List exported to C:\Temp\ACLList.clixml"

    # Export the ACL List to a file
    $getGroupResult.aclList = $ACLList

    #
    # Convert the Permissions into an ACL Token

    $params = @{
        Permissions         = $Permissions
        SecurityNamespace   = $SecurityNamespace
        isInherited         = $isInherited
        OrganizationName    = $OrganizationName
    }

    $DifferenceACLs = ConvertTo-ACL @params



    return $getGroupResult



}

