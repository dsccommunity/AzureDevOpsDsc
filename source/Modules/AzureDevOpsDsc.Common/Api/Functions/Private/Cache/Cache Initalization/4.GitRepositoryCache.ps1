function AzDoAPI_4_GitRepositoryCache
{
    [CmdletBinding()]
    param(
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "[AzDoAPI_4_GitRepositoryCache] Started."

    if (-not $OrganizationName)
    {
        Write-Verbose "[AzDoAPI_4_GitRepositoryCache] No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    # Enumerate the live projects cache
    $AzDoLiveProjects = Get-CacheObject -CacheType 'LiveProjects'

    try
    {
        foreach ($AzDoLiveProject in $AzDoLiveProjects)
        {
            # Log the project being processed
            Write-Verbose "[AzDoAPI_4_GitRepositoryCache] Processing Project '$($AzDoLiveProject.Value.Name)'."
            $ProjectName = $AzDoLiveProject.Value.Name

            # Call the API to get the repositories for the project
            $enumeratedRepositories = List-DevOpsGitRepository -ProjectName $ProjectName -OrganizationName $OrganizationName

            # Log the the git repositories returned by the API call
            Write-Verbose "[AzDoAPI_4_GitRepositoryCache] 'List-DevOpsGitRepository' returned a total of $($enumeratedRepositories.Count) repositories."

            # Iterate through each repository in the response and add them to the cache
            foreach ($repository in $enumeratedRepositories)
            {
                # Log the addition of each repository to the cache
                Write-Verbose "[AzDoAPI_4_GitRepositoryCache] Adding Repository '$($repository.Name)' to the cache."
                # Add the repository to the cache with its name as the key
                Add-CacheItem -Key "$ProjectName\$($repository.Name)" -Value $repository -Type 'LiveRepositories'
            }

        }

        # Export the cache to a file
        Export-CacheObject -CacheType 'LiveGroupMembers' -Content $AzDoLiveRepositories
        Write-Verbose "[AzDoAPI_4_GitRepositoryCache] Completed adding groups to cache."

    }
    catch
    {
        Write-Error "[AzDoAPI_4_GitRepositoryCache] An error occurred: $_"
    }

    Write-Verbose "[AzDoAPI_4_GitRepositoryCache] completed."

}
