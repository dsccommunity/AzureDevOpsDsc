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

    # Group Identity
    $GroupIdentity = Find-AzDoIdentity $GroupName

    # Format the  According to the Group Name
    $Key = Format-AzDoProjectName -GroupName $GroupName -OrganizationName $Global:DSCAZDO_OrganizationName

    # Check the cache for the group
    $LiveGroupMembers = @(Get-CacheItem -Key $Key -Type 'LiveGroupMembers')

    # If the group identity or key is not found, write a warning message to the console and return.
    if ([String]::IsNullOrEmpty($GroupIdentity) -or [String]::IsNullOrWhiteSpace($GroupIdentity)) {
        Write-Warning "[Remove-xAzDoGroupMember] Unable to find identity for group '$GroupName'."
        return
    }

    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[Remove-xAzDoGroupMember] Starting group member removal process for group '$GroupName'."
    Write-Verbose "[Remove-xAzDoGroupMember] Group members: $($LiveGroupMembers.principalName -join ',')."

    # Define the members
    #$members = [System.Collections.Generic.List[object]]::new()

    # Fetch the group members and perform a lookup of the members
    ForEach ($MemberIdentity in $LiveGroupMembers) {

        # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
        Write-Verbose "[Remove-xAzDoGroupMember] Looking up identity for member '$($MemberIdentity.principalName)'."
        $identity = Find-AzDoIdentity -Identity $MemberIdentity.principalName

        # If the identity is not found, write a warning message to the console and continue to the next member.
        if ([String]::IsNullOrEmpty($identity) -or [String]::IsNullOrWhiteSpace($identity)) {
            Write-Warning "[Remove-xAzDoGroupMember] Unable to find identity for member '$($MemberIdentity.principalName)'."
            continue
        }

        # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
        Write-Verbose "[Remove-xAzDoGroupMember] Removing member '$($MemberIdentity.principalName)' from group '$($params.GroupIdentity.displayName)'."

        $result = Remove-DevOpsGroupMember @params -MemberIdentity $identity

    }

    <#
    # If the group members are not found, write a warning message to the console and return.
    if ($members.Count -eq 0) {
        Write-Warning "[Remove-xAzDoGroupMember] No group members found: $($GroupMembers -join ',')."
        return
    }
    #>

    # Add the group to the cache
    Write-Verbose "[Remove-xAzDoGroupMember] Removed group '$GroupName' with members to the cache."
    Remove-CacheItem -Key $GroupIdentity.principalName -Type 'LiveGroupMembers'

    Write-Verbose "[Remove-xAzDoGroupMember] Updated global cache with live group information."
    Set-CacheObject -Content $Global:AzDoLiveGroupMembers -CacheType 'LiveGroupMembers'

    # Write a verbose log message indicating that the function has completed the group member removal process.
    Write-Verbose "[Remove-xAzDoGroupMember] Completed group member removal process for group '$GroupName'."

}
