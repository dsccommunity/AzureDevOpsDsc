<#
.SYNOPSIS
Creates a new project group in Azure DevOps.

.DESCRIPTION
The New-AzDoProjectGroup function creates a new project group in Azure DevOps using the specified API URI and personal access token (PAT). It requires the group display name as a mandatory parameter and allows an optional group description.

.PARAMETER ApiUri
The API URI of the Azure DevOps organization. This parameter is validated using the Test-AzDevOpsApiUri function.

.PARAMETER Pat
The personal access token (PAT) used to authenticate with Azure DevOps. This parameter is validated using the Test-AzDevOpsPat function.

.PARAMETER GroupDisplayName
The display name of the project group. This parameter is mandatory.

.PARAMETER GroupDescription
The description of the project group. This parameter is optional.

.OUTPUTS
[System.Management.Automation.PSObject[]]
An array of PSObjects representing the newly created project group.

.EXAMPLE
New-AzDoProjectGroup -ApiUri 'https://dev.azure.com/contoso' -Pat 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -GroupDisplayName 'MyProjectGroup' -GroupDescription 'This is a sample project group.'

.NOTES
This function requires the Azure DevOpsDsc module to be imported.

.LINK
Test-AzDevOpsApiUri
Test-AzDevOpsPat
New-AzDevOpsGroup
Add-CacheItem
#>

Function New-AzDoProjectGroup {

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
        [Alias('Description')]
        [System.String]$GroupDescription,

        [Parameter()]
        [Alias('Project')]
        [System.String]
        $ProjectName

    )

    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix '[TEAM FOUNDATION]' -GroupName $GroupName

    #
    # Check if the group exists in the cache. If it does throw an error.
    $online_group = Get-CacheItem -Key $Key -Type 'LiveGroups'

    if ($online_group) {
        throw "Group with name '$Key' already exists in the organization."
    }

    #
    # Create a new group

    $result = New-AzDevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription

    #
    # Add the group to the cache
    Add-CacheItem -Key $Key -Value $result -Type 'LiveGroups'

}
