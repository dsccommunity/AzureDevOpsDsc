Function Remove-xAzDoGitPermission {
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

    # Get the Security Namespace
    $SecurityNamespace  = Get-CacheItem -Key 'Git Repositories' -Type 'SecurityNamespaces'

    # If the Security Namespace is null, return
    if (-not $SecurityNamespace) {
        Write-Error "[New-xAzDoGitPermission] Security Namespace not found."
        return
    }

    # Get the Project
    $Project            = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # If the Project is null, return
    if (-not $Project) {
        Write-Error "[New-xAzDoGitPermission] Project not found."
        return
    }

    # Get the Repository
    $Repository         = Get-CacheItem -Key "$ProjectName\$RepositoryName" -Type 'LiveRepositories'

    # If the Repository is null, return
    if (-not $Repository) {
        Write-Error "[New-xAzDoGitPermission] Repository not found."
        return
    }

    # Get the ACLs
    $DescriptorACLList  = Get-CacheItem -Key $SecurityNamespace.namespaceId -Type 'LiveACLList'

    # If the ACLs are null, return
    if (-not $DescriptorACLList) {
        Write-Error "[New-xAzDoGitPermission] ACLs not found."
        return
    }

    #
    # Filter the ACLs that pertain to the Git Repository

    $searchString = "repoV2/{0}/{1}" -f $Project.id, $Repository.id

    # Test if the Token exists
    $Filtered = $DescriptorACLList | Where-Object { $_.token -eq $searchString }

    # If the ACLs are not null, remove them
    if ($Filtered) {

        $params = @{
            OrganizationName = $Global:DSCAZDO_OrganizationName
            SecurityNamespaceID = $SecurityNamespace.namespaceId
            TokenName = $searchString
        }

        # Remove the ACLs
        Remove-xAzDoPermission @params

    }

}
