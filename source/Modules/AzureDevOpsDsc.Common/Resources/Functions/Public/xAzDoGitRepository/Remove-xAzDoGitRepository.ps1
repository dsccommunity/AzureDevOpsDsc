Function Remove-xAzDoGitRepository
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$ProjectName,

        [Parameter(Mandatory)]
        [Alias('Repository')]
        [System.String]$RepositoryName,

        [Parameter()]
        [Alias('Source')]
        [System.String]$SourceRepository,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )


    Write-Verbose "[Remove-xAzDoGitRepository] Removing repository '$($RepositoryName)' in project '$($ProjectName)'"

    # Define parameters for creating a new DevOps group
    $params = @{
        ApiUri = "https://dev.azure.com/{0}/" -f $Global:DSCAZDO_OrganizationName
        Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
        Repository  = Get-CacheItem -Key "$ProjectName\$RepositoryName" -Type 'LiveRepositories'
    }

    # Create a new repository
    $value = Remove-GitRepository @params

    # Add the repository to the LiveRepositories cache and write to verbose log
    Remove-CacheItem -Key "$ProjectName\$RepositoryName" -Type 'LiveRepositories'
    Export-CacheObject -CacheType 'LiveRepositories' -Content $AzDoLiveRepositories
    Write-Verbose "[Remove-xAzDoGitRepository] Added new group to LiveGroups cache with key: '$($value.Name)'"

}
