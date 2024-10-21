<#
.SYNOPSIS
    Tests the membership of a specified Azure DevOps group.

.PARAMETER GroupName
    The name of the Azure DevOps group to test.

.PARAMETER GroupMembers
    An array of members to check within the Azure DevOps group. Default is an empty array.

.PARAMETER LookupResult
    A hashtable containing lookup results for the group members.

.PARAMETER Ensure
    Specifies whether the group members should be present or absent.

.PARAMETER Force
    Forces the operation to proceed without prompting for confirmation.

.NOTES
#>

Function Test-AzDoGroupMember
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

    $return

}
