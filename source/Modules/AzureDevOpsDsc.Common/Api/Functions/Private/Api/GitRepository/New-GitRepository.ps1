Function New-GitRepository {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (

        [Parameter(Mandatory)]
        [Alias('URI')]
        [System.String]$ApiUri,

        [Parameter(Mandatory)]
        [Alias('Name')]
        [Object]$Project,

        [Parameter(Mandatory)]
        [Alias('Repository')]
        [System.String]$RepositoryName,

        [Parameter()]
        [Alias('Source')]
        [System.String]$SourceRepository,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)

    )

    Write-Verbose "[New-GitRepository] Creating new repository '$($RepositoryName)' in project '$($Project.name)'"

    # Define parameters for creating a new DevOps group
    $params = @{
        ApiUri = "{0}/{1}/_apis/git/repositories?api-version={2}" -f $ApiUri, $Project.name, $ApiVersion
        Method = 'POST'
        ContentType = 'application/json'
        Body = @{
            name = $RepositoryName
            project = @{
                id = $Project.id
            }
        } | ConvertTo-Json
    }

    # Try to invoke the REST method to create the group and return the result
    try {
        $repo = Invoke-AzDevOpsApiRestMethod @params
        Write-Verbose "[New-GitRepository] Repository Created: '$($repo.name)'"
        return $repo
    }
    # Catch any exceptions and write an error message
    catch {
        Write-Error "[New-GitRepository] Failed to Create Repository: $_"
    }


}
