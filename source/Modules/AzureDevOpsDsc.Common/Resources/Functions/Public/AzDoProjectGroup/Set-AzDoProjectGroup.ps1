<#
.SYNOPSIS
Sets the Azure DevOps project group.

.DESCRIPTION
This function sets the Azure DevOps project group by specifying the group name, group description, project name, personal access token (PAT), and API URI.

.PARAMETER GroupName
The name of the Azure DevOps project group.

.PARAMETER GroupDescription
The description of the Azure DevOps project group.

.PARAMETER ProjectName
The name of the Azure DevOps project.

.PARAMETER Pat
The personal access token (PAT) used for authentication.

.PARAMETER ApiUri
The URI of the Azure DevOps API.

.EXAMPLE
Set-AzDoProjectGroup -GroupName "MyGroup" -GroupDescription "Group for My Project" -ProjectName "MyProject" -Pat "********" -ApiUri "https://dev.azure.com/myorganization"

This example sets the Azure DevOps project group with the specified parameters.

#>

Function Set-AzDoProjectGroup {

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter()]
        [string]
        $GroupDescription=$null,

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

    # Format the Key According to the Principal Name
    $Key = Format-UserPrincipalName -Prefix $ProjectName -GroupName $GroupName

    #
    # Check the cache for the group
    $group = Get-CacheItem -Key $Key -Type 'LiveGroups'

    $params = @{
        ApiUri = $ApiUri
        Pat = $Pat
        GroupName = $GroupName
        GroupDescription = $GroupDescription
        ProjectScopeDescriptor = Get-AzDevOpsSecurityDescriptor -ProjectName $ProjectName -Organization $Global:DSCAZDO_OrganizationName
    }

    # Set the group from the API
    $group = Set-AzDevOpsGroup @params

    #
    # Update the cache with the new group

    #
    # Add the group to the cache
    Add-CacheItem -Key $Key -Value $result.value -Type 'LiveGroups'

    return $group.Value

}
