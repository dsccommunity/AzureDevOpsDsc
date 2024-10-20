Function AzDoAPI_2_UserCache {

    [CmdletBinding()]
    param(
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
        foreach ($user in $users) {
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
