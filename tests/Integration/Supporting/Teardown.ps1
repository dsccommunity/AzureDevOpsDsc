[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $ClearAll,

    [Parameter()]
    [Switch]
    $ClearOrganizationGroups,

    [Parameter()]
    [Switch]
    $ClearProjects,

    [Parameter()]
    [String]
    $OrganizationName,

    [Parameter()]
    [Object]
    $TestFrameworkConfiguration

)

$Global:DSCAZDO_AuthenticationToken = Get-MIToken -OrganizationName $OrganizationName

#
# Remove Projects
if ($ClearAll -or $ClearProjects)
{
    # List all projects and remove them
    List-DevOpsProjects -OrganizationName $OrganizationName | Where-Object { $_.Name -notin $TestFrameworkConfiguration.excludedProjectsFromTeardown }  | ForEach-Object {
        Remove-DevOpsProject -ProjectId $_.id -Organization $OrganizationName
    }
}

#
# Remove Organization Groups

if ($ClearAll -or $ClearOrganizationGroups)
{
    # List all groups and remove them
    List-DevOpsGroups -Organization $OrganizationName | Where-Object {
        ($_.DisplayName -notlike "Project*") -and ($_.DisplayName -notlike "Security*") -and ($_.DisplayName -notlike "Service*") -and ($_.DisplayName -notlike "Team*") -and ($_.DisplayName -notlike "Enterprise*")
    } | ForEach-Object {
        Remove-DevOpsGroup -GroupDescriptor $_.descriptor -OrganizationName $OrganizationName
    }
}
