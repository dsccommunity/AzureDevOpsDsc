function Set-AzDoAPIGroupMemberCache
{
    [CmdletBinding()]
    param(
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "Starting 'Set-GroupCache' function."

    if (-not $OrganizationName)
    {
        Write-Verbose "No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    $params = @{}

    # Enumerate the live group cache
    $AzDoLiveGroups = Get-CacheObject -CacheType 'LiveGroups'

    try
    {
        ForEach ($AzDoLiveGroup in $AzDoLiveGroups)
        {
            # Update the Group ID in the parameters
            $GroupID = $AzDoLiveGroup.Value.originId

            $params.url =

            Write-Verbose "Calling 'List-DevOpsGroupMembers' with parameters: $($params | Out-String)"

            # Perform an Azure DevOps API request to get the groups
            $groupMembers = List-DevOpsGroupMembers -URL $AzDoLiveGroup.value._links.memberships.href

            Write-Verbose "'List-DevOpsGroupMembers' returned a total of $($groupMembers.Count) group members."

            Write-Verbose "Adding group id '$($AzDoLiveGroup.originId)' to cache."
            # Add the group to the cache
            Add-CacheItem -Key $group.PrincipalName -Value $group -Type 'LiveGroups'

        }


        # Iterate through each of the responses and add them to the cache
        foreach ($group in $groups)
        {

        }

        # Export the cache to a file
        Export-CacheObject -CacheType 'LiveGroups' -Content $AzDoLiveGroups

        Write-Verbose "Completed adding groups to cache."

    }
    catch
    {
        Write-Error "An error occurred: $_"
    }

    Write-Verbose "Function 'Set-AzDoAPICacheGroup' completed."

}
