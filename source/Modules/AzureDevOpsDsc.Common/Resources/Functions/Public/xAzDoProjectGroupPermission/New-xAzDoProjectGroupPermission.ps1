Function New-xAzDoProjectGroupPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [HashTable[]]$GroupName

        [Parameter(Mandatory)]
        [string]$ProjectName,

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


    Write-Verbose "[New-xAzDoProjectGroupPermission] Started."

    #
    # Security Namespace ID

    $SecurityNamespace = Get-CacheItem -Key 'Identity' -Type 'SecurityNamespaces'
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    #
    # Serialize the ACLs

    # TODO UPDATE SerializeACLs
    $serializeACLParams = @{
        ReferenceACLs = $LookupResult.propertiesChanged
        DescriptorACLList = Get-CacheItem -Key $SecurityNamespace.namespaceId -Type 'LiveACLList'
        DescriptorMatchToken = ($LocalizedDataAzSerilizationPatten.GitRepository -f $Project.id)
    }

    $params = @{
        OrganizationName = $Global:DSCAZDO_OrganizationName
        SecurityNamespaceID = $SecurityNamespace.namespaceId
        SerializedACLs = ConvertTo-ACLHashtable @serializeACLParams
    }

    #
    # Set the Git Repository Permissions

    Set-GitRepositoryPermission @params

}
