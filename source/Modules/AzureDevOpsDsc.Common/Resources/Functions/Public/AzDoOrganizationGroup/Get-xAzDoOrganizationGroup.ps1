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
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [DscProperty()]
        [Alias('DisplayName')]
        [System.String]$GroupDisplayName,

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription

    )

    #
    # Define the Current State
    $CurrentState = [xAzDoOrganizationGroup]::New()
    $CurrentState.DisplayName = $GroupDisplayName
    $CurrentState.Name = $GroupName
    $CurrentState.Description = $GroupDescription

    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Check the cache for the group
    $livegroup = Get-CacheItem -Key $Key -Type 'LiveGroups'

    #
    # Check if the group is in the cache
    $localgroup = Get-CacheItem -Key $Key -Type 'Group'

    #
    #


    #
    # Construct a hashtable detailing the group

    switch ($localgroup) {
        # If the group is present in the live cache and the local cache.
        { ($null -ne $livegroup) -and ($null -ne $_)} {
            # Test if the originId is the same. If so, the group is unchanged. If not, the group has been renamed.
            $DscGetResult.Status = ($livegroup.originId -ne $_.originId) ? [DSCGroupTestResult]::Renamed : [DSCGroupTestResult]::Unchanged
            break;
        }

        # If the group is not present in the live cache. Flag as Not Found.
        { ($null -eq $livegroup) } {
            $DscGetResult.Status = [DSCGroupTestResult]::NotFound
            break;
        }

        # If the group is not present in the local cache. Flag as Missing.
        { ($null -eq $_) } {
            $DscGetResult.Status = [DSCGroupTestResult]::Missing
            break;
        }

        # All other cases are changed.
        default {
            $DscGetResult.Status = [DSCGroupTestResult]::Changed
            break;
        }

    }

    #
    # Return the group from the cache

    return $DscGetResult

}
