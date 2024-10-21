<#
.SYNOPSIS
Initializes the Git repository cache for Azure DevOps projects.

.DESCRIPTION
The AzDoAPI_4_GitRepositoryCache function initializes the Git repository cache by enumerating live projects and retrieving their repositories from Azure DevOps. The repositories are then added to the cache.

.PARAMETER OrganizationName
The name of the Azure DevOps organization. If not provided, the function uses the global variable $Global:DSCAZDO_OrganizationName.

.EXAMPLE
AzDoAPI_4_GitRepositoryCache -OrganizationName "MyOrganization"
Initializes the Git repository cache for the specified Azure DevOps organization.

.EXAMPLE
AzDoAPI_4_GitRepositoryCache
Initializes the Git repository cache using the global organization name variable.

.NOTES
This function uses verbose logging to indicate the progress and actions taken during the cache initialization process. It also handles errors by logging them as errors.

#>
function AzDoAPI_4_GitRepositoryCache
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
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
        Export-CacheObject -CacheType 'LiveRepositories' -Content $AzDoLiveRepositories
        Write-Verbose "[AzDoAPI_4_GitRepositoryCache] Completed adding groups to cache."

    }
    catch
    {
        Write-Error "[AzDoAPI_4_GitRepositoryCache] An error occurred: $_"
    }

    Write-Verbose "[AzDoAPI_4_GitRepositoryCache] completed."

}
