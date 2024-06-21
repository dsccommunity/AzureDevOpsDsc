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
    $descriptorType = 'Git Repositories'
    $OrganizationName = $Global:AZDOOrganizationName

    #
    # Construct a hashtable detailing the group
    $getGroupResult = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        status = $null
        project = $project
        repositoryName = $RepositoryName
    }

    #
    # Perform Lookup of the Permissions for the Repository

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecruityDescriptorId    = (Get-CacheItem -Key 'GitRepositories' -Type 'SecurityNamespaces').value.namespaceId
    }

    # Get the ACL List
    $ACLList = Get-DevOpsACL @ACLLookupParams




    return $getGroupResult


}

