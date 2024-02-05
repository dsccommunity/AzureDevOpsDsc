<#
.SYNOPSIS
Creates a token for Azure DevOps access control.

.DESCRIPTION
The New-AzDevOpsACLToken function creates a token for Azure DevOps access control.
The token can be used to grant access at either the project level or the team level.

.PARAMETER OrganizationName
The name of the Azure DevOps organization.

.PARAMETER ProjectId
The ID of the Azure DevOps project.

.PARAMETER TeamId
The ID of the Azure DevOps team. If not specified, the token will be created for project-level access.

.EXAMPLE
New-AzDevOpsACLToken -OrganizationName "Contoso" -ProjectId "MyProject" -TeamId "MyTeam"
Creates a token for team-level access to the specified Azure DevOps project and team.

.EXAMPLE
New-AzDevOpsACLToken -OrganizationName "Contoso" -ProjectId "MyProject"
Creates a token for project-level access to the specified Azure DevOps project.
#>

function New-AzDevOpsACLToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter()]
        [string]$TeamId
    )

    process {
        if ($TeamId) {
            # Construct a token for team-level access
            $token = "vstfs:///Classification/TeamProject/$ProjectId/$TeamId"
        } else {
            # Construct a token for project-level access
            $token = "vstfs:///Classification/TeamProject/$ProjectId"
        }

        return $token
    }

}
