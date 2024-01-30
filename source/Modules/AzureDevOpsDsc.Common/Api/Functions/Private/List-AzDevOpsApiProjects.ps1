
# Assuming we have a global cache variable (hashtable) to store project lists
$Global:AzDevOpsProjectsCache = @{}

function Get-AzDevOpsProjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter()]
        [string]$PersonalAccessToken
    )

    # Define the cache key based on the organization name
    $cacheKey = "projects_$OrganizationName"

    try {
        # Check if the projects are already cached
        if ($Global:AzDevOpsProjectsCache.ContainsKey($cacheKey)) {
            Write-Host "Retrieving projects from cache for organization: $OrganizationName"
            # Return the cached list of projects
            return $Global:AzDevOpsProjectsCache[$cacheKey]
        } else {
            Write-Host "Fetching projects from Azure DevOps REST API for organization: $OrganizationName"
            # The base URL for Azure DevOps REST API calls
            $baseUrl = "https://dev.azure.com/$OrganizationName"
            # The specific endpoint for listing projects within an organization
            $projectsApiUrl = "$baseUrl/_apis/projects?api-version=6.0"

            # Set up the authorization header using the Personal Access Token
            if ($PersonalAccessToken) {
                $authHeader = @{
                    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken"))
                }
            } else {
                throw "A Personal Access Token is required to access Azure DevOps REST API."
            }

            # Make the REST API call to get the list of projects
            $response = Invoke-RestMethod -Uri $projectsApiUrl -Method Get -Headers $authHeader

            # Check if the response contains value indicating successful retrieval of projects
            if ($response.value) {
                # Cache the list of projects
                $Global:AzDevOpsProjectsCache[$cacheKey] = $response.value
                # Return the list of projects
                return $response.value
            } else {
                throw "No projects were found in the specified organization."
            }
        }
    } catch {
        Write-Error "Failed to retrieve projects from Azure DevOps: $_"
    }
}
