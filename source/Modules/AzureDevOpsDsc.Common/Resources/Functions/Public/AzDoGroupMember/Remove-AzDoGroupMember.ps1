<#
.SYNOPSIS
Removes members from an Azure DevOps group.

.DESCRIPTION
The Remove-AzDoGroupMember function removes specified members from an Azure DevOps group.
It looks up the group identity, checks the cache for existing group members, and removes the specified members.

.PARAMETER GroupName
The name of the Azure DevOps group from which members will be removed.

.PARAMETER GroupMembers
An array of group members to be removed. This parameter is optional.

.PARAMETER LookupResult
A hashtable containing lookup results. This parameter is optional.

.PARAMETER Ensure
Specifies whether to ensure the removal of the group members. This parameter is optional.

.PARAMETER Force
A switch parameter to force the removal of group members without confirmation.

.EXAMPLE
Remove-AzDoGroupMember -GroupName "Developers" -GroupMembers "user1@example.com", "user2@example.com"

This command removes the specified members from the "Developers" group.

.EXAMPLE
Remove-AzDoGroupMember -GroupName "Developers" -Force

This command forces the removal of all members from the "Developers" group without confirmation.

.NOTES
This function requires the Azure DevOps module and appropriate permissions to manage group memberships.

#>
Function Remove-AzDoGroupMember
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

    # Group Identity
    $GroupIdentity = Find-AzDoIdentity $GroupName

    # Format the  According to the Group Name
    $Key = Format-AzDoProjectName -GroupName $GroupName -OrganizationName $Global:DSCAZDO_OrganizationName

    # Check the cache for the group
    $LiveGroupMembers = @(Get-CacheItem -Key $Key -Type 'LiveGroupMembers')

    # If the group identity or key is not found, write a warning message to the console and return.
    if ([String]::IsNullOrEmpty($GroupIdentity) -or [String]::IsNullOrWhiteSpace($GroupIdentity))
    {
        Write-Warning "[Remove-AzDoGroupMember] Unable to find identity for group '$GroupName'."
        return
    }

    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[Remove-AzDoGroupMember] Starting group member removal process for group '$GroupName'."
    Write-Verbose "[Remove-AzDoGroupMember] Group members: $($LiveGroupMembers.principalName -join ',')."

    # Fetch the group members and perform a lookup of the members
    ForEach ($MemberIdentity in $LiveGroupMembers)
    {

        # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
        Write-Verbose "[Remove-AzDoGroupMember] Looking up identity for member '$($MemberIdentity.principalName)'."
        $identity = Find-AzDoIdentity -Identity $MemberIdentity.principalName

        # If the identity is not found, write a warning message to the console and continue to the next member.
        if ([String]::IsNullOrEmpty($identity) -or [String]::IsNullOrWhiteSpace($identity))
        {
            Write-Warning "[Remove-AzDoGroupMember] Unable to find identity for member '$($MemberIdentity.principalName)'."
            continue
        }

        # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
        Write-Verbose "[Remove-AzDoGroupMember] Removing member '$($MemberIdentity.principalName)' from group '$($params.GroupIdentity.displayName)'."

        $result = Remove-DevOpsGroupMember @params -MemberIdentity $identity

    }

    # Add the group to the cache
    Write-Verbose "[Remove-AzDoGroupMember] Removed group '$GroupName' with members to the cache."
    Remove-CacheItem -Key $GroupIdentity.principalName -Type 'LiveGroupMembers'

    Write-Verbose "[Remove-AzDoGroupMember] Updated global cache with live group information."
    Set-CacheObject -Content $Global:AzDoLiveGroupMembers -CacheType 'LiveGroupMembers'

    # Write a verbose log message indicating that the function has completed the group member removal process.
    Write-Verbose "[Remove-AzDoGroupMember] Completed group member removal process for group '$GroupName'."

}
