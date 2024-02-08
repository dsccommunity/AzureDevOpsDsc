<#
.SYNOPSIS
Removes an Azure DevOps project group.

.DESCRIPTION
The Remove-AzDoProjectGroup function removes an Azure DevOps project group from the API and cache. It first checks if the group exists in the live cache, and if not, retrieves it from the API. Then, it removes the group from the API and removes it from the cache and live cache.

.PARAMETER ApiUri
The URI of the Azure DevOps API.

.PARAMETER Pat
The Personal Access Token (PAT) used for authentication.

.PARAMETER GroupDisplayName
The display name of the project group to remove.

.OUTPUTS
[System.Management.Automation.PSObject[]]
The removed project group.

.EXAMPLE
Remove-AzDoProjectGroup -ApiUri 'https://dev.azure.com/contoso' -Pat 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -GroupDisplayName 'MyProjectGroup'

This example removes the project group with the display name 'MyProjectGroup' from the Azure DevOps organization at 'https://dev.azure.com/contoso' using the specified PAT.

#>
Function Remove-AzDoProjectGroup {

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

        [Parameter(Mandatory)]
        [Alias('DisplayName')]
        [System.String]$GroupDisplayName,

        [Parameter()]
        [Alias('Project')]
        [System.String]
        $ProjectName

    )

    #
    # Format the Key According to the Principal Name

    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupDisplayName

    #
    # Check if the group exists in the live cache.

    $group = Get-CacheItem -Key $Key -Type 'LiveGroups'

    if ($null -eq $group) {
        Throw "Group with name '$Key' does not exist in the organization."
    }

    #
    # Remove the group from the API
    $params = @{
        ApiUri = $ApiUri
        GroupDescriptor = $group.Descriptor
    }

    # Remove the group from the API
    $null = Remove-AzDevOpsGroup @params

    #
    # Remove the group from the cache and live cache

    Remove-CacheItem -Key $Key -Type 'LiveGroups'

}
