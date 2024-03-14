<#
.SYNOPSIS
Sets the Azure DevOps API project cache.

.DESCRIPTION
This function sets the Azure DevOps API project cache by making an API request to get the projects and adding them to the cache.

.PARAMETER OrganizationName
Specifies the name of the organization. If not provided, the function uses a global variable as a fallback.

.EXAMPLE
Set-AzDoAPIProjectCache -OrganizationName "MyOrganization"
This example sets the Azure DevOps API project cache for the organization "MyOrganization".

.INPUTS
None.

.OUTPUTS
None.

.NOTES
Author: [Author Name]
Date: [Date]
#>

Function Set-AzDoAPIProjectCache {
    [CmdletBinding()]
    param(
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "Starting 'Set-AzDoAPIProjectCache' function."

    if (-not $OrganizationName) {
        # If no organization name is provided, use a global variable as fallback
        Write-Verbose "No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    # Create a hashtable to store parameters for API call
    $params = @{
        Organization = $OrganizationName
    }

    try {
        # Inform about the API call being made with the parameters
        Write-Verbose "Calling 'List-DevOpsProjects' with parameters: $($params | Out-String)"

        # Perform an Azure DevOps API request to get the projects
        $projects = List-DevOpsProjects @params

        # Log the total number of projects returned by the API call
        Write-Verbose "'List-DevOpsProjects' returned a total of $($projects.value.Count) projects."

        # Iterate through each project in the response and add them to the cache
        foreach ($project in $projects.value) {
            # Log the addition of each project to the cache
            Write-Verbose "Adding Project '$($project.Name)' to the cache."

            # Add the project to the cache with its name as the key
            Add-CacheItem -Key $project.Name -Value $project -Type 'LiveProjects'
        }

        # Indicate completion of adding projects to cache
        Write-Verbose "Completed adding projects to cache."

    } catch {
        # Handle any exceptions that occur during the try block
        Write-Error "An error occurred: $_"
    }

    # Signal the end of the function execution
    Write-Verbose "Function 'Set-AzDoAPIProjectCache' completed."
}
