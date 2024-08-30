Function New-xAzDoGroupMember {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
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
    Write-Verbose "[New-xAzDoGroupMember] Starting group member addition process for group '$GroupName'."

    # Fetch the Group Identity
    $GroupIdentity = Find-AzDoIdentity $GroupName
    Write-Verbose "[New-xAzDoGroupMember] Fetched group identity for '$GroupName'."

    # Retrieve the group members from the cache
    $CachedGroupMembers = Get-CacheObject -CacheType 'LiveGroupMembers'
    Write-Verbose "[New-xAzDoGroupMember] Retrieved cached group members."

    # Check if the group members are already cached
    if (($null -ne $CachedGroupMembers) -and ($CachedGroupMembers.ContainsKey($GroupIdentity.principalName))) {
        Write-Error "[New-xAzDoGroupMember] Group members are already cached for group '$GroupName'."
        return
    }


    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[New-xAzDoGroupMember] Starting group member addition process for group '$GroupName'."
    Write-Verbose "[New-xAzDoGroupMember] Group members: $($GroupMembers -join ',')."

    # Define the members
    $members = [System.Collections.Generic.List[object]]::new()

    # Fetch the group members and perform a lookup of the members
    ForEach ($MemberIdentity in $GroupMembers) {

        # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
        Write-Verbose "[New-xAzDoGroupMember] Looking up identity for member '$MemberIdentity'."
        $identity = Find-AzDoIdentity -Identity $MemberIdentity

        # If the identity is not found, write a warning message to the console and continue to the next member.
        if ($null -eq $identity) {
            Write-Warning "[New-xAzDoGroupMember] Unable to find identity for member '$MemberIdentity'."
            continue
        }

        # Check for circular reference
        if ($GroupIdentity.originId -eq $identity.originId) {
            Write-Warning "[New-xAzDoGroupMember] Circular reference detected for member '$MemberIdentity'."
            continue
        }

        Write-Verbose "[New-xAzDoGroupMember] Found identity for member '$MemberIdentity'."

        # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
        Write-Verbose "[New-xAzDoGroupMember] Adding member '$MemberIdentity' to group '$($params.GroupIdentity.displayName)'."

        $result = New-DevOpsGroupMember @params -MemberIdentity $identity

        # Add the member to the list
        $members.Add($identity)
        Write-Verbose "[New-xAzDoGroupMember] Member '$MemberIdentity' added to the internal list."
    }

    # If the group members are not found, write a warning message to the console and return.
    if ($members.Count -eq 0) {
        Write-Warning "[New-xAzDoGroupMember] No group members found: $($GroupMembers -join ',')."
        return
    }

    # Add the group to the cache
    Write-Verbose "[New-xAzDoGroupMember] Added group '$GroupName' with members to the cache."
    Add-CacheItem -Key $GroupIdentity.principalName -Value $members -Type 'LiveGroupMembers'

    Write-Verbose "[New-xAzDoGroupMember] Updated global cache with live group information."
    Set-CacheObject -Content $Global:AzDoLiveGroupMembers -CacheType 'LiveGroupMembers'

    # Write a verbose log message indicating that the function has completed the group member addition process.
    Write-Verbose "[New-xAzDoGroupMember] Completed group member addition process for group '$GroupName'."

}
