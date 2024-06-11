Function Remove-GitRepository {
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
        [Object]$Repository

    )

    Write-Verbose "[Remove-GitRepository] Removing repository '$($Repository.Name)' in project '$($Project.name)'"

    # Define parameters for creating a new DevOps group
    $params = @{
        ApiUri = "{0}/{1}/_apis/git/repositories/{2}" -f $ApiUri, $Project.name, $Repository.id
        Method = 'Delete'
    }

    # Try to invoke the REST method to create the group and return the result
    try {
        $null = Invoke-AzDevOpsApiRestMethod @params
        return
    }
    # Catch any exceptions and write an error message
    catch {
        Write-Error "[Remove-GitRepository] Failed to Create Repository: $_"
    }


}
