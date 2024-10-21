<#
.SYNOPSIS
Initializes and populates the user cache for Azure DevOps.

.DESCRIPTION
The `AzDoAPI_2_UserCache` function initializes and populates the user cache by retrieving user information from Azure DevOps.
It uses the provided organization name or a global variable if no organization name is provided. The function retrieves the
user list, adds each user to the cache, and then exports the cache to a file.

.PARAMETER OrganizationName
The name of the Azure DevOps organization. If not provided, the function will use the global variable `$Global:DSCAZDO_OrganizationName`.

.EXAMPLE
PS> AzDoAPI_2_UserCache -OrganizationName "MyOrganization"
This example initializes and populates the user cache for the specified Azure DevOps organization "MyOrganization".

.NOTES
- This function uses the `List-UserCache` cmdlet to retrieve the list of users.
- Each user is added to the cache using the `Add-CacheItem` cmdlet.
- The cache is exported to a file using the `Export-CacheObject` cmdlet.
- Verbose output is provided to indicate the progress and actions of the function.
#>
Function AzDoAPI_2_UserCache
{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "[AzDoAPI_2_UserCache] Starting 'AzDoAPI_2_UserCache' function."

    if (-not $OrganizationName)
    {
        Write-Verbose "[AzDoAPI_2_UserCache] No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    $params = @{
        Organization = $OrganizationName
    }

    try
    {
        Write-Verbose "[AzDoAPI_2_UserCache] Calling 'AzDoAPI_2_UserCache' with parameters: $($params | Out-String)"
        # Perform an Azure DevOps API request to get the groups

        $users = List-UserCache @params

        Write-Verbose "[AzDoAPI_2_UserCache] 'AzDoAPI_2_UserCache' returned a total of $($users.Count) users."

        # Iterate through each of the responses and add them to the cache
        foreach ($user in $users)
        {
            Write-Verbose "[AzDoAPI_2_UserCache] Adding user '$($user.PrincipalName)' to cache."
            # Add the group to the cache
            Add-CacheItem -Key $user.PrincipalName -Value $user -Type 'LiveUsers'
        }

        # Export the cache to a file
        Export-CacheObject -CacheType 'LiveUsers' -Content $AzDoLiveUsers

        Write-Verbose "[AzDoAPI_2_UserCache] Completed adding users to cache."

    }
    catch
    {
        Write-Error "[AzDoAPI_2_UserCache] An error occurred: $_"
    }

    Write-Verbose "[AzDoAPI_2_UserCache] Function 'Set-AzDoAPICacheGroup' completed."

}
