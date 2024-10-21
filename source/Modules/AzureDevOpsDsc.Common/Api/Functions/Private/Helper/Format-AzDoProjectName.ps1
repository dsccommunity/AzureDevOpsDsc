<#
.SYNOPSIS
Formats the Azure DevOps project name.

.DESCRIPTION
This function formats the Azure DevOps project name by ensuring it follows the correct format.
If the group name is already in the format '[Project|Organization]\GroupName', it returns the group name as is.
Otherwise, it splits the group name and ensures it has the correct format.

.PARAMETER GroupName
The name of the group. This parameter is mandatory.

.PARAMETER OrganizationName
The name of the organization. This parameter is mandatory.

.EXAMPLE
PS> Format-AzDoProjectName -GroupName 'Project\Group' -OrganizationName 'MyOrg'
[Project]\Group

.EXAMPLE
PS> Format-AzDoProjectName -GroupName '%ORG%\Group' -OrganizationName 'MyOrg'
[MyOrg]\Group

.EXAMPLE
PS> Format-AzDoProjectName -GroupName '%TFS%\Group' -OrganizationName 'MyOrg'
[TEAM FOUNDATION]\Group

.NOTES
If the group name is not in the correct format, an error is thrown.
#>
Function Format-AzDoProjectName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter(Mandatory = $true)]
        [Alias('Organization')]
        [System.String]$OrganizationName
    )

    # Logging
    Write-Verbose "[Format-AzDoProjectName] Formatting GroupName."

    # If the GroupName contains [Project|Organization]\GroupName, it's in the correct format.
    if ($GroupName -match '^\[.*\]\\.*$')
    {
        return $GroupName
    }

    # Split the group name with a '\' or '/' and create an array.
    $splitGroupName = $GroupName -split '\\|\/'

    # There must be at least 2 elements in the array. The first element is the project name and the second element is the group name.
    if ($splitGroupName.Length -lt 2)
    {
        Throw "The GroupName '$GroupName' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName' or 'Project/GroupName."
    }

    # If the first element contains '%ORG%' or is empty, replace it with the organization name.
    if ($splitGroupName[0] -eq '%ORG%' -or [String]::IsNullOrEmpty($splitGroupName[0].Trim()))
    {
        $splitGroupName[0] = $OrganizationName
    }
    elseif ($splitGroupName[0].Trim() -eq '%TFS%')
    {
        # If the first element contains '%TFS%', replace it with 'TEAM FOUNDATION'.
        $splitGroupName[0] = 'TEAM FOUNDATION'
    }

    # The group name cannot be null.
    if ([String]::IsNullOrEmpty($splitGroupName[1].Trim()))
    {
        Throw "The GroupName '$GroupName' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName'."
    }

    # Format the group name with the organization name.
    $formattedGroupName = '[{0}]\{1}' -f $splitGroupName[0].Trim(), $splitGroupName[1].Trim()

    return $formattedGroupName
}
