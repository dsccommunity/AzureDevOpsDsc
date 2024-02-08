<#
.SYNOPSIS
    Tests if a project group exists in Azure DevOps.

.DESCRIPTION
    The Test-AzDoProjectGroup function is used to check if a project group exists in Azure DevOps.
    It takes the group name, project name, personal access token (PAT), and API URI as parameters.
    It then formats the key according to the principal name and checks the cache for the group.
    If the group is found in the cache, it returns $true; otherwise, it returns $false.

.PARAMETER GroupName
    Specifies the name of the project group to test.

.PARAMETER ProjectName
    Specifies the name of the project. This parameter is optional.
    If not provided, the function will not validate the project name.

.PARAMETER Pat
    Specifies the personal access token (PAT) to authenticate with Azure DevOps.

.PARAMETER ApiUri
    Specifies the API URI of the Azure DevOps instance.

.EXAMPLE
    Test-AzDoProjectGroup -GroupName "MyGroup" -ProjectName "MyProject" -Pat "********" -ApiUri "https://dev.azure.com/myorg"

    This example tests if the project group named "MyGroup" exists in the project "MyProject" in Azure DevOps.
    It uses the specified personal access token (PAT) and API URI to authenticate with Azure DevOps.

#>
Function Test-AzDoProjectGroup {

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('ProjectName')]
        [System.String]
        $ProjectName,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri

    )

    #
    # Check the cache for the group

    $group = Get-CacheItem -Key $ProjectName -Type 'LiveGroups'

    if (-not($group)) { $false } else { $true }

}
