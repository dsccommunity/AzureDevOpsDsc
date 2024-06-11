

Function Get-xAzDoGitRepository {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$ProjectName

        [Parameter(Mandatory)]
        [Alias('Repository')]
        [System.String]$RepositoryName,

        [Parameter()]
        [Alias('Source')]
        [System.String]$SourceRepository

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    #
    # Construct a hashtable detailing the group

    $getRepositoryResult = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        liveCache = $livegroup
        propertiesChanged = @()
        status = $null
    }


    #
    # Attempt to retrive the Project Group from the Live and Local Cache.
    Write-Verbose "[Get-xAzDoGitRepository] Retriving the Project Group from the Live and Local Cache."

    # Format the Key for the Project Group.
    $projectGroupKey = "$ProjectName\$RepositoryName"

    # Retrive the Repositories from the Live Cache.
    $repository = Get-CacheItem -Key $projectGroupKey -Type 'LiveRepositories'

    # If the Repository exists in the Live Cache, return the Repository object.
    if ($repository) {
        Write-Verbose "[Get-xAzDoGitRepository] The Repository '$RepositoryName' was found in the Live Cache."
        $getRepositoryResult.status = [DSCGetSummaryState]::Unchanged
    } else {
        Write-Verbose "[Get-xAzDoGitRepository] The Repository '$RepositoryName' was not found in the Live Cache."
        $getRepositoryResult.status = [DSCGetSummaryState]::NotFound
    }

    # Return the Repository object.
    return $getRepositoryResult

}
