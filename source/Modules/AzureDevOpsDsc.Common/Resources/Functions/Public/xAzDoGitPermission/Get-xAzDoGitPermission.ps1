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

    #
    #
    Write-Verbose "[Get-xAzDoGitPermission] Started."

    #
    # Perform Lookup of the Permissions for the Repository

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecruityDescriptorId    = (Get-CacheItem -Key 'GitRepositories' -Type 'SecurityNamespaces').value.namespaceId
    }

    # Get the ACL List
    $ACLList = Get-DevOpsACL @ACLLookupParams

    #
    # Process the ACL list breaking down by ACL it's inhertance and permissions



    #
    # TypeCast the Permissions to a Permission[] array

    $descriptorType = 'GitRepositories'

    $formatDescriptorType = Format-DescriptorType -DescriptorType $descriptorType
    $params = @{
        Permissions = $Permissions
        DescriptorType = $descriptorType
        SecurityNamespace = Get-CacheItem -Key $formatDescriptorType -Type 'SecurityNamespaces'
    }

    Write-Verbose "[Get-xAzDoGitPermission] Converting Permissions to Permission object."

    $var = ConvertTo-Permission @params

}

