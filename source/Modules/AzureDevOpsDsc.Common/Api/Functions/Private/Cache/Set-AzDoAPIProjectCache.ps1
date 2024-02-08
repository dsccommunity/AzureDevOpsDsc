Function Set-AzDoAPIProjectCache {
    [CmdletBinding()]
    param(
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "Starting 'Set-AzDoAPIProjectCache' function."

    if (-not $OrganizationName) {
        Write-Verbose "No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    $params = @{
        Organization = $OrganizationName
    }

    try {

        Write-Verbose "Calling 'List-DevOpsProjects' with parameters: $($params | Out-String)"
        # Perform an Azure DevOps API request to get the groups
        $projects = List-DevOpsProjects @params

        Write-Verbose "'List-DevOpsProjects' returned a total of $($groups.value.Count) groups."

        # Iterate through each of the responses and add them to the cache
        foreach ($projects in $projects.value) {
            Write-Verbose "Adding Project '$($projects.Name)' to the cache."
            # Add the group to the cache
            Add-CacheItem -Key $projects.Name -Value $projects -Type 'LiveProjects'
        }

        Write-Verbose "Completed adding groups to cache."

    } catch {

        Write-Error "An error occurred: $_"

    }

    Write-Verbose "Function 'Set-AzDoAPIProjectCache' completed."

}
