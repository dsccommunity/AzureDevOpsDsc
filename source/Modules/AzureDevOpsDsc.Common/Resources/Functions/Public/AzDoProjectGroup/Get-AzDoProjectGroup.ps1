<#

.SYNOPSIS
Retrieves a project group from Azure DevOps.

.DESCRIPTION
The Get-AzDoProjectGroup function retrieves a project group from Azure DevOps based on the provided parameters.

.PARAMETER ApiUri
The URI of the Azure DevOps API. This parameter is validated using the Test-AzDevOpsApiUri function.

.PARAMETER Pat
The Personal Access Token (PAT) used for authentication. This parameter is validated using the Test-AzDevOpsPat function.

.PARAMETER GroupName
The name of the project group to retrieve. This parameter is mandatory.

.PARAMETER ProjectName
The name of the project associated with the project group.

.OUTPUTS
[System.Management.Automation.PSObject[]]
An array of PSObjects representing the retrieved project group.

.EXAMPLE
Get-AzDoProjectGroup -ApiUri 'https://dev.azure.com/contoso' -Pat 'xxxxxxxxxxxxxxxxxxxx' -GroupName 'MyGroup' -ProjectName 'MyProject'

This example retrieves the project group named 'MyGroup' from the Azure DevOps instance at 'https://dev.azure.com/contoso' using the provided PAT and project name.

#>

Function Get-AzDoProjectGroup {

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
        [Alias('Name')]
        [System.String]
        $GroupName,

        [Parameter()]
        [Alias('Project')]
        [System.String]
        $ProjectName

    )

    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix $ProjectName -GroupName $GroupName

    #
    # Check the cache for the group
    $group = Get-CacheItem -Key $Key -Type 'LiveGroups'

    #
    # Return the group from the cache

    return $group.Value

}
