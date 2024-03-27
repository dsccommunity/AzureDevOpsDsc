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
        [Parameter()]
        [Alias('DisplayName')]
        [System.String]$GroupDisplayName,

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription

    )

    # Logging
    Write-Verbose "[Get-xAzDoOrganizationGroup] Retriving the GroupName from the Live and Local Cache."

    #
    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Check the cache for the group
    $livegroup = Get-CacheItem -Key $Key -Type 'LiveGroups'

    #
    # Check if the group is in the cache
    $localgroup = Get-CacheItem -Key $Key -Type 'Group'


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
    # If the localgroup and lifegroup are present, compare the properties as well as the originId
    if (($null -ne $livegroup.originId) -and ($null -ne $localgroup.originId)) {

        Write-Verbose "[Get-xAzDoOrganizationGroup] Testing LocalCache, LiveCache and Parameters."

        #
        # Check if the originId is the same. If so, the group is unchanged. If not, the group has been renamed.

        if ($livegroup.originId -ne $localgroup.originId) {
            # The group has been renamed or deleted and recreated.

            # Perform a lookup in the live cache to see if the group has been deleted and recreated.
            $renamedGroup = $livegroup | Find-CacheItem { $_.originId -eq $livegroup.originId }

            # If renamed group is not null, the group has been renamed.
            if ($null -ne $renamedGroup) {
                # Add the renamed group to result
                $getGroupResult.renamedGroup = $renamedGroup
                # The group has been renamed.
                $getGroupResult.status = [DSCGetSummaryState]::Renamed

                # Add the reason
                #$getGroupResult.Reasons += [DscResourceReason]::New('xAzDoOrganizationGroup:xAzDoOrganizationGroup:RenamedGroup', 'The group was renamed')

            } else {
                # The group has been deleted and recreated. Treat the new group as the live group.

                # Remove the old group from the local cache
                Remove-CacheItem -Key $Key -Type 'Group'
                # Add the new group to the local cache
                Add-CacheItem -Key $Key -Value $livegroup -Type 'Group'

                # Compare the properties of the live group with the parameters
                if ($livegroup.displayName -ne $groupDisplayName) { $getGroupResult.propertiesChanged += 'DisplayName' }
                if ($livegroup.description -ne $groupDescription) { $getGroupResult.propertiesChanged += 'Description' }
                if ($livegroup.name -ne $localgroup.name) { $getGroupResult.propertiesChanged += 'Name' }

                # If the properties are the same, the group is unchanged. If not, the group has been changed.
                if ($getGroupResult.propertiesChanged.count -ne 0) {
                    # Update the Result
                    $getGroupResult.status = [DSCGetSummaryState]::Changed
                    # Add the reason
                    #$getGroupResult.Reasons += [DscResourceReason]::New('xAzDoOrganizationGroup:xAzDoOrganizationGroup:Deleted&ReCreate', 'The group was deleted and recreated with another group. The properties have changed')
                } else {
                    # Update the Result
                    $getGroupResult.status = [DSCGetSummaryState]::Unchanged
                }

            }

            return $getGroupResult

        }

        #
        # The Group hasn't been renamed. Test the properties to make sure they are the same as the parameters.

        # Compare the properties of the live group with the parameters
        if ($livegroup.displayName -ne $groupDisplayName) { $getGroupResult.propertiesChanged += 'DisplayName' }
        if ($livegroup.description -ne $groupDescription) { $getGroupResult.propertiesChanged += 'Description' }
        if ($livegroup.name -ne $localgroup.name) { $getGroupResult.propertiesChanged += 'Name' }

        # If the properties are the same, the group is unchanged. If not, the group has been changed.
        $getGroupResult.status = ($getGroupResult.propertiesChanged.count -ne 0) ? [DSCGetSummaryState]::Changed : [DSCGetSummaryState]::Unchanged
        if ($getGroupResult.status -eq [DSCGetSummaryState]::Changed) {
            # Add the reason
            #$getGroupResult.Reasons += [DscResourceReason]::New('xAzDoOrganizationGroup:xAzDoOrganizationGroup:Changed', 'The group has changed')
        } else {
            $getGroupResult.Ensure = [Ensure]::Present
        }

        # Return the group from the cache
        return $getGroupResult

    }

    #
    # If the livegroup is not present and the localgroup is present, the group is missing and recreate it.
    if (($null -eq $livegroup) -and ($null -ne $localgroup)) {
        $getGroupResult.status = [DSCGetSummaryState]::NotFound
        $getGroupResult.propertiesChanged = @('DisplayName', 'Description', 'Name')
        # Add the reason
        #$getGroupResult.Reasons += [DscResourceReason]::New('xAzDoOrganizationGroup:xAzDoOrganizationGroup:Removed', 'The group is missing')
        return $getGroupResult
    }

    #
    # If the localgroup is not present and the livegroup is present, the group is not found. Check the properties are the same as the parameters.
    # If the properties are the same, the group is unchanged. If not, the group has been deleted and then recreated.
    #
    if (($null -eq $localgroup) -and ($null -ne $livegroup)) {

        # Validate that the live properties are the same as the parameters
        if ($livegroup.displayName -ne $groupDisplayName) { $getGroupResult.propertiesChanged += 'DisplayName' }
        if ($livegroup.description -ne $groupDescription) { $getGroupResult.propertiesChanged += 'Description' }
        if ($livegroup.name        -ne $localgroup.name ) { $getGroupResult.propertiesChanged += 'Name'        }
        # If the properties are the same, the group is unchanged. If not, the group has been changed.
        $getGroupResult.status = ($getGroupResult.propertiesChanged.count -ne 0) ? [DSCGetSummaryState]::Renamed : [DSCGetSummaryState]::Unchanged
        if ($getGroupResult.status -ne [DSCGetSummaryState]::Unchanged) {
            # Add the reason
            #$getGroupResult.Reasons += [DscResourceReason]::New('xAzDoOrganizationGroup:xAzDoOrganizationGroup:Missing', 'The group is missing')
        } else {
            # Add the unchanged group to the local cache
            Add-CacheItem -Key $Key -Value $livegroup -Type 'Group'
            # Set the Ensure to Present
            $getGroupResult.Ensure = [Ensure]::Present
        }

        # Return the group from the cache
        return $getGroupResult

    }

    #
    # If the livegroup and localgroup are not present, the group is missing and recreate it.
    if (($null -eq $livegroup) -and ($null -eq $localgroup)) {
        $getGroupResult.status = [DSCGetSummaryState]::NotFound
        $getGroupResult.propertiesChanged = @('DisplayName', 'Description', 'Name')
        # Add the reason
        #$getGroupResult.Reasons += [DscResourceReason]::New('xAzDoOrganizationGroup:xAzDoOrganizationGroup:NotFound', 'The group is not found')
        return $getGroupResult
    }

}
