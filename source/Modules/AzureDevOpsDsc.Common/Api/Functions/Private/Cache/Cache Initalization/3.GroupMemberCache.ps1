function AzDoAPI_3_GroupMemberCache
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

    $params = @{
        Organization = $OrganizationName
    }

    # Enumerate the live group cache
    $AzDoLiveGroups = Get-CacheObject -CacheType 'LiveGroups'
    # Enumerate the live users cache
    $AzDoLiveUsers = Get-CacheObject -CacheType 'LiveUsers'

    try
    {
        ForEach ($AzDoLiveGroup in $AzDoLiveGroups)
        {
            # Update the Group ID in the parameters
            $GroupDescriptor = $AzDoLiveGroup.Value.descriptor

            Write-Verbose "Calling 'AzDoAPI_2_GroupMemberCache' with parameters: $($params | Out-String)"

            # Perform an Azure DevOps API request to get the groups
            $groupMembers = List-DevOpsGroupMembers -Organization $OrganizationName -GroupDescriptor $GroupDescriptor

            # If there are no members, skip to the next group
            if ($null -eq $groupMembers.memberDescriptor)
            {
                Write-Verbose "No members found for group '$($AzDoLiveGroup.Key)'; skipping."
                continue
            }

            # Members
            $members = [System.Collections.Generic.List[object]]::new()

            # Iterate through each of the users and groups and add them to the cache
            $azdoUserMembers = $AzDoLiveUsers.value | Where-Object { $_.descriptor -in $groupMembers.memberDescriptor }
            $azdoGroupMembers = $AzDoLiveGroups.value | Where-Object { $_.descriptor -in $groupMembers.memberDescriptor }

            $azdoUserMembers | Select-Object *,@{Name="Type";Exp={"user"}} | Where-Object { $_.descriptor -in $groupMembers.memberDescriptor } | ForEach-Object {
                $null = $members.Add($_)
            }

            $azdoGroupMembers | Select-Object *,@{Name="Type";Exp={"group"}} | Where-Object { $_.descriptor -in $groupMembers.memberDescriptor } | ForEach-Object {
                $null = $members.Add($_)
            }

            # Add the group to the cache
            Add-CacheItem -Key $AzDoLiveGroup.value.PrincipalName -Value $members -Type 'LiveGroupMembers'

        }

        # Export the cache to a file
        Export-CacheObject -CacheType 'LiveGroupMembers' -Content $AzdoLiveGroupMembers

        Write-Verbose "Completed adding groups to cache."

    }
    catch
    {
        Write-Error "An error occurred: $_"
    }

    Write-Verbose "Function 'Set-AzDoAPICacheGroup' completed."

}
