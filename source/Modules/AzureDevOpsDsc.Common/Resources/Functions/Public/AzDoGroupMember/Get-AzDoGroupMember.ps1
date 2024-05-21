<#
.SYNOPSIS
Retrieves an organization group from Azure DevOps.

.DESCRIPTION
The Get-xAzDoOrganizationGroup function retrieves an organization group from Azure DevOps based on the provided parameters.

.PARAMETER ApiUri
The URI of the Azure DevOps API. This parameter is validated using the Test-AzDevOpsApiUri function.

.PARAMETER Pat
The Personal Access Token (PAT) used for authentication. This parameter is validated using the Test-AzDevOpsPat function.

.PARAMETER GroupName
The name of the organization group to retrieve.

.OUTPUTS
[System.Management.Automation.PSObject[]]
The retrieved organization group.

.EXAMPLE
Get-xAzDoOrganizationGroup -ApiUri 'https://dev.azure.com/contoso' -Pat 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx' -GroupName 'Developers'
Retrieves the organization group named 'Developers' from the Azure DevOps instance at 'https://dev.azure.com/contoso' using the provided PAT.

#>

Function Get-xAzDoOrganizationGroup {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=$null,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure

    )

    # Logging
    Write-Verbose "[Get-xAzDoOrganizationGroup] Retriving the GroupName from the Live and Local Cache."

    #
    # Format the Key According to the Principal Name
   # $Key = Format-UserPrincipalName -Prefix "[$Global:DSCAZDO_OrganizationName]" -GroupName $GroupName

    #
    # Check the cache for the group members
    $livegroupMembers = Get-CacheItem -Key $Key -Type 'LiveGroupMembers'


    Write-Verbose "[Get-xAzDoOrganizationGroup] GroupName: '$GroupName'"

    #
    # Construct a hashtable detailing the group
    $getGroupResult = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        localCache = $localgroup
        liveCache = $livegroup
        propertiesChanged = @()
        status = $null
    }

    Write-Verbose "[Get-xAzDoOrganizationGroup] Testing LocalCache, LiveCache and Parameters."

    #
    # Test if the group is present in the live cache
    if ($null -eq $livegroupMembers) {

        # If there are no group members, test to see if there are group members defined in the parameters
        if ($GroupMembers.Count -eq 0) {
            $getGroupResult.status = [DSCGetSummaryState]::Unchanged
        } else {
            $getGroupResult.status = [DSCGetSummaryState]::Changed
        }

        # Return the result
        return $getGroupResult
    }

    #
    # Test if there are no group memebers in parameters
    if ($GroupMembers.Count -eq 0) {

        # If there are no live group members, the group is unchanged.
        if ($livegroupMembers.Count -eq 0) {
            $getGroupResult.status = [DSCGetSummaryState]::Unchanged
        } else {
            # If there are live group members, the group has been changed.
            $getGroupResult.status = [DSCGetSummaryState]::Changed
        }

        # Return the result
        return $getGroupResult
    }

    #
    # If both parameters and group members exist.

    # Compare the members of the live group with the parameters.

    # Format the parameters

    $FormattedLiveGroups = @()
    $FormattedParametersGroups = @()

    #
    # Compare the live group members with the parameters

    $params = @{
        ReferenceObject = $FormattedParametersGroups
        DifferenceObject = $FormattedLiveGroups
    }

    try {

        #
        # Compare the group members
        $members = Compare-Object @Params

    } catch {

        # If an error occurs, assume the group has changed.
        $getGroupResult.status = [DSCGetSummaryState]::Changed
        return $getGroupResult

    }

    #
    # If there are no differences, the group is unchanged.

    if ($members.Count -eq 0) {
        $getGroupResult.status = [DSCGetSummaryState]::Unchanged
    } else {

        # Users on the left side are in the comparison object but not in the reference object are to be added.
        # Users on the right side are in the reference object but not in the comparison object are to be removed.
        $getGroupResult.propertiesChanged += $members | ForEach-Object {
            @{
                action = ($_.SideIndicator -eq '<=') ? 'Add' : 'Remove'
                value = $_.InputObject
            }
        }

        # The group has changed.
        $getGroupResult.status = [DSCGetSummaryState]::Changed

    }

    return $getGroupResult

}
