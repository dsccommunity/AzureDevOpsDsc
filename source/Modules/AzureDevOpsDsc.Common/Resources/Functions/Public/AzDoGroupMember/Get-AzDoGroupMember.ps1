<#
.SYNOPSIS
Retrieves the members of an Azure DevOps group and compares them with the provided parameters.

.DESCRIPTION
The Get-AzDoGroupMember function retrieves the members of an Azure DevOps group from the live cache and compares them with the provided parameters. It returns a hashtable detailing the group status, including any differences between the live group members and the provided parameters.

.PARAMETER GroupName
The name of the Azure DevOps group to retrieve.

.PARAMETER GroupMembers
An array of group members to compare against the live group members. Default is an empty array.

.PARAMETER LookupResult
A hashtable to store lookup results.

.PARAMETER Ensure
Specifies whether the group should be present or absent.

.PARAMETER Force
A switch parameter to force the operation.

.OUTPUTS
System.Management.Automation.PSObject[]
A hashtable detailing the group status, including any differences between the live group members and the provided parameters.

.EXAMPLE
PS C:\> Get-AzDoGroupMember -GroupName "Developers" -GroupMembers @("user1", "user2")

This command retrieves the members of the "Developers" group and compares them with the provided members "user1" and "user2".

.NOTES
This function uses verbose logging to provide detailed information about its operations.
#>

Function Get-AzDoGroupMember
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

    # Logging
    Write-Verbose "[Get-AzDoGroupMember] Retriving the GroupName from the Live and Local Cache."

    # Format the  According to the Group Name
    $Key = Format-AzDoGroupMember -GroupName $GroupName

    # Check the cache for the group
    $livegroupMembers = Get-CacheItem -Key $Key -Type 'LiveGroupMembers'

    Write-Verbose "[Get-AzDoGroupMember] GroupName: '$GroupName'"

    #
    # Construct a hashtable detailing the group
    $getGroupResult = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        groupName = $GroupName
        reference = $GroupMembers
        difference = $livegroupMembers
        propertiesChanged = @()
        status = $null
    }

    Write-Verbose "[Get-AzDoGroupMember] Testing LocalCache, LiveCache and Parameters."

    #
    # Test if the group is present in the live cache
    if ($null -eq $livegroupMembers)
    {
        Write-Verbose "[Get-AzDoGroupMember] Group '$GroupName' not found in the live cache."
        # If there are no group members, test to see if there are group members defined in the parameters
        if ($GroupMembers.Count -eq 0)
        {
            $getGroupResult.status = [DSCGetSummaryState]::Unchanged
        }
        else
        {
            # If there are group members defined in the parameters, but no live group members, the group is new.
            $getGroupResult.status = [DSCGetSummaryState]::NotFound
        }

        # Return the result
        return $getGroupResult
    }

    #
    # Test if there are no group members in parameters
    if ($GroupMembers.Count -eq 0)
    {
        Write-Verbose "[Get-AzDoGroupMember] Group '$GroupName' not found in the parameters."

        # If there are no live group members, the group is unchanged.
        if ($livegroupMembers.Count -eq 0)
        {
            $getGroupResult.status = [DSCGetSummaryState]::Unchanged
        }
        else
        {
            # If there are live group members, the groups members are to be removed.
            $getGroupResult.status = [DSCGetSummaryState]::Missing
        }

        # Return the result
        return $getGroupResult
    }

    #
    # If both parameters and group members exist.

    # Compare the members of the live group with the parameters.

    # Format the parameters
    $FormattedLiveGroups = @($livegroupMembers)
    $FormattedParametersGroups = $GroupMembers | ForEach-Object { Find-AzDoIdentity $_ }

    # If the formatted live groups is empty. Modify the formatted live groups to be an empty array.
    if ($null -eq $FormattedLiveGroups)
    {
        $FormattedLiveGroups = @()
    }

    #
    # Compare the live group members with the parameters

    $params = @{
        ReferenceObject = $FormattedParametersGroups
        DifferenceObject = $FormattedLiveGroups
        Property = 'originId'
    }

    #
    # Compare the group members
    $members = Compare-Object @Params -ErrorAction SilentlyContinue

    #
    # If there are no differences, the group is unchanged.

    if ($members.Count -eq 0)
    {
        # The group is unchanged.
        $getGroupResult.status = [DSCGetSummaryState]::Unchanged
    }
    else
    {
        # Users on the left side are in the comparison object but not in the reference object are to be added.
        # Users on the right side are in the reference object but not in the comparison object are to be removed.
        $getGroupResult.propertiesChanged += $members | ForEach-Object {
            $originId = $_.originId
            @{
                action = ($_.SideIndicator -eq '<=') ? 'Add' : 'Remove'
                value = ($FormattedParametersGroups | Where-Object { $_.originId -eq $originId }) ??
                        ($FormattedLiveGroups | Where-Object { $_.originId -eq $originId })

            }
        }
        # The group has changed.
        $getGroupResult.status = [DSCGetSummaryState]::Changed
    }

    return $getGroupResult

}
