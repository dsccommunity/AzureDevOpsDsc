

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
    # Attempt to retrive the Project Group from the Live and Local Cache.

    Write-Verbose "[Get-xAzDoGitRepository] Retriving the Project Group from the Live and Local Cache."

    # Retrive the Project
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # If the Project is not found in the Live Cache, write a warning
    if (-not $project) {
        Write-Warning "[Get-xAzDoGitRepository] The Project '$ProjectName' was not found in the Live Cache."
    }

    # Attempt to retrive the Git Repository from the Live Cache.




}
