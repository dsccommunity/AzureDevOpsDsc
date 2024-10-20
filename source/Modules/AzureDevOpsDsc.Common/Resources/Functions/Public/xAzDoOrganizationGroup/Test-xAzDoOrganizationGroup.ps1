<#
.SYNOPSIS
    Tests if an organization group exists in Azure DevOps.

.DESCRIPTION
    The Test-AzDoOrganizationGroup function checks if a specified organization group exists in Azure DevOps.
    It uses a personal access token (PAT) and the Azure DevOps API to perform the check.

.PARAMETER GroupName
    Specifies the name of the organization group to test.

.PARAMETER Pat
    Specifies the personal access token (PAT) to authenticate with Azure DevOps.
    The PAT is validated using the Test-AzDevOpsPat function.

.PARAMETER ApiUri
    Specifies the URI of the Azure DevOps API to connect to.
    The URI is validated using the Test-AzDevOpsApiUri function.

.OUTPUTS
    System.Boolean
    Returns $true if the organization group exists, otherwise returns $false.

.EXAMPLE
    Test-xAzDoOrganizationGroup -GroupName 'MyGroup' -Pat '********' -ApiUri 'https://dev.azure.com/myorg'

    Description
    -----------
    Tests if the organization group named 'MyGroup' exists in the Azure DevOps organization 'myorg'
    using the specified personal access token and API URI.

#>
Function Test-xAzDoOrganizationGroup {

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter()]
        [string]
        $GroupDescription=$null,

        [Parameter()]
        [Alias('Name')]
        [hashtable]$GetResult

    )

    #
    # Firstly we need to compare to see if the group names are the same. If so we can return $false.

    if ($GetResult.Status -eq [DSCGetSummaryState]::Unchanged ) {

        $result = $true

        if ($GroupDescription -eq $GetResult.Current.description)
        {
            $GetResult.
            $result = $false
        }

        return $true }

    #
    # If the status has been flagged as 'Renamed', returned $true. This means that the originId has changed.
    if ($GetResult.Status -eq [DSCGetSummaryState]::Renamed) { return $false }

    #
    # If the status has been flagged as 'Missing', returned $true. This means that the group is missing from the live cache.



    if ($GetResult.Status -eq [DSCGetSummaryState]::Changed) {

        #
        # If the group is present in the live cache and the local cache. This means that the originId has changed. This needs to be updated.
        if (($null -ne $GetResult.Current) -and ($null -ne $GetResult.Cache)) {
            return $true
        }

        #
        # If the group is present in the live cache but not in the local cache. Flag as Changed.
        if ($GetResult.Current -and -not($GetResult.Cache)) {
            return $true
        }

        #
        # If the group is not present in the live cache but is in the local cache. Flag as Changed.
        if (-not($GetResult.Current) -and $GetResult.Cache) {
            return $true
        }

    }


    # Format the Key According to the Principal Name
    $Key = Format-AzDoGroup -Prefix "[$Global:DSCAZDO_OrganizationName]" -GroupName $GroupName

    #
    # Check the cache for the group
    $group = Get-CacheItem -Key $Key -Type 'LiveGroups'
    if (-not($group)) { $false } else { $true }

}
