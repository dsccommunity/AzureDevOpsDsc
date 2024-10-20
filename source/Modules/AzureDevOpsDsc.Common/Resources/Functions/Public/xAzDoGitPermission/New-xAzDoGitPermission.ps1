Function New-xAzDoGitPermission {
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

    Write-Verbose "[New-xAzDoGitPermission] Started."

    #
    # Security Namespace ID

    $SecurityNamespace = Get-CacheItem -Key 'Git Repositories' -Type 'SecurityNamespaces'
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    if (($null -eq $SecurityNamespace) -or ($null -eq $Project)) {
        Write-Warning "[New-xAzDoGitPermission] Security Namespace or Project not found."
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

    Set-xAzDoPermission @params

}
