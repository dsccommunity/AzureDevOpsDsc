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
    Test-AzDoOrganizationGroup -GroupName 'MyGroup' -Pat '********' -ApiUri 'https://dev.azure.com/myorg'

    Description
    -----------
    Tests if the organization group named 'MyGroup' exists in the Azure DevOps organization 'myorg'
    using the specified personal access token and API URI.

#>
Function Test-AzDevOpsxAzDoOrganizationGroup {

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter()]
        [Alias('Name')]
        [System.String]$GetResult

    )

    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Check the cache for the group
    $group = Get-CacheItem -Key $Key -Type 'LiveGroups'
    if (-not($group)) { $false } else { $true }

}
