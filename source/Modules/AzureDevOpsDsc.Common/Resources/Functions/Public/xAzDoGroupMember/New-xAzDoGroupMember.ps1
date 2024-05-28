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
    $GroupIdentity =  Find-AzDoIdentity $GroupName
    Write-Verbose "[New-xAzDoGroupMember] Fetched group identity for '$GroupName'."

    # Retrieve the group members from the cache
    $CachedGroupMembers = Get-CacheObject -CacheType 'LiveGroupMembers'
    Write-Verbose "[New-xAzDoGroupMember] Retrieved cached group members."

    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vsaex.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    # Define the members
    $members = [System.Collections.Generic.List[object]]::new()

    # Fetch the group members and perform a lookup of the members
    ForEach ($MemberIdentity in $GroupMembers) {

        # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
        $identity = Find-AzDoIdentity -Identity $MemberIdentity
        Write-Verbose "[New-xAzDoGroupMember] Found identity for member '$MemberIdentity'."

        # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
        $result = New-DevOpsGroupMember @params -MemberIdentity $identity

        # Add the member to the list
        $members.Add($identity)
        Write-Verbose "[New-xAzDoGroupMember] Member '$MemberIdentity' added to the internal list."
    }

    # Add the group to the cache
    Add-CacheItem -Key $GroupIdentity.value.principalName -Value $members -Type 'LiveGroups'
    Write-Verbose "[New-xAzDoGroupMember] Added group '$GroupName' with members to the cache."

    Set-CacheObject -Content $Global:AZDOLiveGroups -CacheType 'LiveGroups'
    Write-Verbose "[New-xAzDoGroupMember] Updated global cache with live group information."

    # Write a verbose log message indicating that the function has completed the group member addition process.
    Write-Verbose "[New-xAzDoGroupMember] Completed group member addition process for group '$GroupName'."

}
