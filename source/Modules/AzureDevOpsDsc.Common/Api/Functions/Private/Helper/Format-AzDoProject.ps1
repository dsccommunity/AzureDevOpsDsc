Function Format-AzDoProjectName {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter(Mandatory)]
        [Alias('Organization')]
        [System.String]$OrganizationName
    )

    # Logging
    Write-Verbose "[Format-AzDoProjectName] Formatting GroupName."

    # Split the group name with a '\' and create an array.
    $splitGroupName = $GroupName -split '\\'

    # There must be at least 2 elements in the array. The first element is the project name and the second element is the group name.
    if ($splitGroupName.Length -lt 2) {
        Throw "The GroupName '$GroupName' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName'."
    }

    # If the first element contains '%ORG%' or is empty, replace it with the organization name.
    if ($splitGroupName[0] -eq '%ORG%' -or [String]::IsNullOrEmpty($splitGroupName[0].Trim())) {
        $splitGroupName[0] = $OrganizationName
    # If the first element contains '%TFS%', replace it with 'TEAM FOUNDATION'.
    } elseif ($splitGroupName[0].Trim() -eq '%TFS%') {
        $splitGroupName[0] = 'TEAM FOUNDATION'
    }

    # The group name cannot be null.
    if ([String]::IsNullOrEmpty($splitGroupName[1].Trim())) {
        Throw "The GroupName '$GroupName' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName'."
    }

    # Format the group name with the organization name.
    $formattedGroupName = '[{0}]\{1}' -f $splitGroupName[0], $splitGroupName[1]

    return $formattedGroupName
}
