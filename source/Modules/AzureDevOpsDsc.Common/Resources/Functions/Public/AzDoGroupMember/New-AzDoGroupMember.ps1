<#
.SYNOPSIS
    Adds members to an Azure DevOps group.

.DESCRIPTION
    The New-AzDoGroupMember function adds specified members to an Azure DevOps group.
    It fetches the group identity, retrieves cached group members, and performs a lookup
    for each member to add them to the group. The function also handles circular references
    and updates the cache with the new group members.

.PARAMETER GroupName
    The name of the Azure DevOps group to which members will be added.

.PARAMETER GroupMembers
    An array of member identities to be added to the group. Default is an empty array.

.PARAMETER LookupResult
    A hashtable containing lookup results.

.PARAMETER Ensure
    Specifies whether to ensure the presence or absence of the group members.

.PARAMETER Force
    A switch parameter to force the addition of members even if they are already cached.

.EXAMPLE
    PS> New-AzDoGroupMember -GroupName "Developers" -GroupMembers "user1", "user2"

    This example adds "user1" and "user2" to the "Developers" group.

.NOTES
    The function writes verbose messages to indicate the progress of the group member addition process.
    It also handles errors and warnings for cases such as circular references and missing identities.
#>

Function New-AzDoGroupMember
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=@(),

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    # Write a verbose log message indicating that the function has started executing.
    Write-Verbose "[New-AzDoGroupMember] Starting group member addition process for group '$GroupName'."

    # Fetch the Group Identity
    $GroupIdentity = Find-AzDoIdentity $GroupName
    Write-Verbose "[New-AzDoGroupMember] Fetched group identity for '$GroupName'."

    # Retrieve the group members from the cache
    $CachedGroupMembers = Get-CacheObject -CacheType 'LiveGroupMembers'
    Write-Verbose "[New-AzDoGroupMember] Retrieved cached group members."

    # Check if the group members are already cached
    if (
        ($null -ne $CachedGroupMembers) -and
        (($CachedGroupMembers | Where-Object { $_.Key -eq $GroupIdentity.principalName }).Count -ne 0)
    )
    {
        Write-Error "[New-AzDoGroupMember] Group members are already cached for group '$GroupName'."
        return
    }

    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[New-AzDoGroupMember] Starting group member addition process for group '$GroupName'."
    Write-Verbose "[New-AzDoGroupMember] Group members: $($GroupMembers -join ',')."

    # Define the members
    $members = [System.Collections.Generic.List[object]]::new()

    # Fetch the group members and perform a lookup of the members
    ForEach ($MemberIdentity in $GroupMembers)
    {
        # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
        Write-Verbose "[New-AzDoGroupMember] Looking up identity for member '$MemberIdentity'."
        $identity = Find-AzDoIdentity -Identity $MemberIdentity

        # If the identity is not found, write a warning message to the console and continue to the next member.
        if ($null -eq $identity)
        {
            Write-Warning "[New-AzDoGroupMember] Unable to find identity for member '$MemberIdentity'."
            continue
        }

        # Check for circular reference
        if ($GroupIdentity.originId -eq $identity.originId)
        {
            Write-Warning "[New-AzDoGroupMember] Circular reference detected for member '$MemberIdentity'."
            continue
        }

        Write-Verbose "[New-AzDoGroupMember] Found identity for member '$MemberIdentity'."

        # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
        Write-Verbose "[New-AzDoGroupMember] Adding member '$MemberIdentity' to group '$($params.GroupIdentity.displayName)'."

        $result = New-DevOpsGroupMember @params -MemberIdentity $identity

        # Add the member to the list
        $members.Add($identity)
        Write-Verbose "[New-AzDoGroupMember] Member '$MemberIdentity' added to the internal list."
    }

    # If the group members are not found, write a warning message to the console and return.
    if ($members.Count -eq 0)
    {
        Write-Warning "[New-AzDoGroupMember] No group members found: $($GroupMembers -join ',')."
        return
    }

    # Add the group to the cache
    Write-Verbose "[New-AzDoGroupMember] Added group '$GroupName' with members to the cache."
    Add-CacheItem -Key $GroupIdentity.principalName -Value $members -Type 'LiveGroupMembers'

    Write-Verbose "[New-AzDoGroupMember] Updated global cache with live group information."
    Set-CacheObject -Content $Global:AzDoLiveGroupMembers -CacheType 'LiveGroupMembers'

    # Write a verbose log message indicating that the function has completed the group member addition process.
    Write-Verbose "[New-AzDoGroupMember] Completed group member addition process for group '$GroupName'."

}
