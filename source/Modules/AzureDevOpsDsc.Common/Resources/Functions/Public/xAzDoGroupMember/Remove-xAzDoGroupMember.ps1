Function Remove-xAzDoGroupMember {

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

    # Fetch the Group Identity
    $GroupIdentity = Find-AzDoIdentity $GroupName

    # Retrieve the group members from the cache
    $CachedGroupMembers = Get-CacheObject -CacheType 'LiveGroupMembers'

    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[Remove-xAzDoGroupMember] Starting group member removal process for group '$GroupName'."
    Write-Verbose "[Remove-xAzDoGroupMember] Group members: $($GroupMembers -join ',')."

    # Define the members
    $members = [System.Collections.Generic.List[object]]::new()

    # Fetch the group members and perform a lookup of the members
    ForEach ($MemberIdentity in $GroupMembers) {

        # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
        Write-Verbose "[Remove-xAzDoGroupMember] Looking up identity for member '$MemberIdentity'."
        $identity = Find-AzDoIdentity -Identity $MemberIdentity

        # If the identity is not found, write a warning message to the console and continue to the next member.
        if ($null -eq $identity) {
            Write-Warning "[Remove-xAzDoGroupMember] Unable to find identity for member '$MemberIdentity'."
            continue
        }
        Write-Verbose "[Remove-xAzDoGroupMember] Found identity for member '$MemberIdentity'."

        # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
        Write-Verbose "[Remove-xAzDoGroupMember] Removing member '$MemberIdentity' to group '$($params.GroupIdentity.displayName)'."

        $result = Remove-DevOpsGroupMember @params -MemberIdentity $identity

    }

    # If the group members are not found, write a warning message to the console and return.
    if ($members.Count -eq 0) {
        Write-Warning "[Remove-xAzDoGroupMember] No group members found: $($GroupMembers -join ',')."
        return
    }

    # Add the group to the cache
    Write-Verbose "[Remove-xAzDoGroupMember] Added group '$GroupName' with members to the cache."
    Remove-CacheItem -Key $GroupIdentity.principalName -Type 'LiveGroupMembers'

    Write-Verbose "[Remove-xAzDoGroupMember] Updated global cache with live group information."
    Set-CacheObject -Content $Global:AZDOLiveGroups -CacheType 'LiveGroupMembers'

    # Write a verbose log message indicating that the function has completed the group member removal process.
    Write-Verbose "[Remove-xAzDoGroupMember] Completed group member removal process for group '$GroupName'."

}
