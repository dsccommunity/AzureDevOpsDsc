<#
.SYNOPSIS
    Manages Azure DevOps group members by adding or removing members based on the provided lookup result.

.PARAMETER GroupName
    The name of the Azure DevOps group to manage.

.PARAMETER GroupMembers
    An array of group members to be managed. Defaults to an empty array.

.PARAMETER LookupResult
    A hashtable containing the propertiesChanged key which indicates the action to be performed (Add or Remove).

.PARAMETER Ensure
    Specifies whether the group members should be present or absent.

.PARAMETER Force
    A switch parameter to force the operation.

.DESCRIPTION
    The Set-AzDoGroupMember function manages Azure DevOps group members by adding or removing members based on the provided lookup result.
    It checks for circular references and updates the internal cache with the new group member information.

.EXAMPLE
    Set-AzDoGroupMember -GroupName "Developers" -GroupMembers @("user1", "user2") -LookupResult $lookupResult -Ensure "Present"

    This example adds the specified members to the "Developers" group based on the lookup result.

.NOTES
    The function relies on several helper functions such as Find-AzDoIdentity, Format-AzDoProjectName, Get-CacheItem, New-DevOpsGroupMember, Remove-DevOpsGroupMember, Add-CacheItem, and Set-CacheObject.
    Ensure that these functions are defined and available in the scope where Set-AzDoGroupMember is called.

#>

Function Set-AzDoGroupMember
{
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=@(),

        [Parameter()]
        [Alias('Lookup')]
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
    $members = [System.Collections.ArrayList]::New()
    Get-CacheItem -Key $Key -Type 'LiveGroupMembers' | ForEach-Object { $members.Add($_) }

    # If the members are null or empty, stop.
    if (($null -eq $GroupMembers) -or ($members.Count -eq 0))
    {
        Write-Error "[Set-AzDoGroupMember] No members found in the LiveGroupMembers cache for group '$Key'."
        return
    }

    # If the lookup result is not provided, we need to look it up.
    if ($null -eq $LookupResult.propertiesChanged)
    {
        Throw "[Set-AzDoGroupMember] - LookupResult.propertiesChanged is required."
    }

    # Fetch the Group Identity
    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[Set-AzDoGroupMember] Starting group member addition process for group '$GroupName'."

    # If the lookup result is not provided, we need to look it up.
    switch ($LookupResult.propertiesChanged)
    {

        # Add members
        { $_.action -eq "Add" } {

            # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
            Write-Verbose "[Set-AzDoGroupMember][ADD] Adding Identity for Principal Name '$($_.value.principalName)'."
            $identity = $_.value

            # Check for circular reference
            if ($GroupIdentity.originId -eq $identity.originId)
            {
                Write-Warning "[Set-AzDoGroupMember][ADD] Circular reference detected for member '$($GroupIdentity.principalName)'."
                continue
            }

            # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
            Write-Verbose "[Set-AzDoGroupMember][ADD] Adding member '$($identity.displayName)' to group '$($params.GroupIdentity.displayName)'."

            $result = New-DevOpsGroupMember @params -MemberIdentity $identity

            # Add the member to the list
            $members.Add($identity)
            Write-Verbose "[Set-AzDoGroupMember][ADD] Member '$($identity.displayName)' added to the internal list."

        }

        # Remove
        { $_.action -eq "Remove" } {

            # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
            Write-Verbose "[Set-AzDoGroupMember][REMOVE] Removing Identity for Principal Name '$($_.value.principalName)'."
            $identity = $_.value

            # Check for circular reference
            if ($GroupIdentity.originId -eq $identity.originId)
            {
                Write-Warning "[Set-AzDoGroupMember][REMOVE] Circular reference detected for member '$($GroupIdentity.principalName)'."
                continue
            }

            # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
            Write-Verbose "[Set-AzDoGroupMember][REMOVE] Removing member '$($identity.displayName)' to group '$($params.GroupIdentity.displayName)'."

            $result = Remove-DevOpsGroupMember @params -MemberIdentity $identity

            # Remove the member from the list

            Write-Verbose "[Set-AzDoGroupMember][REMOVE] Removing member '$($identity.displayName)' from the internal list."
            Write-Verbose "[Set-AzDoGroupMember][REMOVE] members count: $($members.count)"

            $id = 0 .. $members.count | Where-Object { $members[$_].originId -eq $identity.originId }
            $members.RemoveAt($id)
            Write-Verbose "[Set-AzDoGroupMember][REMOVE] Member '$($identity.displayName)' removed from the internal list."

        }

        # Default
        Default {
            Write-Warning "[Set-AzDoGroupMember] Invalid action '$($_.action)' provided."
        }

    }

    # Add the group to the cache
    Write-Verbose "[Set-AzDoGroupMember] Added group '$GroupName' with the updated member list to the cache."
    Add-CacheItem -Key $GroupIdentity.principalName -Value $members -Type 'LiveGroupMembers'

    Write-Verbose "[Set-AzDoGroupMember] Updated global cache with live group information."
    Set-CacheObject -Content $Global:AzDoLiveGroupMembers -CacheType 'LiveGroupMembers'

}
