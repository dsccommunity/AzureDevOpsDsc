<#
.SYNOPSIS
    Checks batch permissions for a user in Azure DevOps.

.DESCRIPTION
    The Test-AzDevOpsBatchPermissions function checks batch permissions for a user in Azure DevOps.
    It sends a request to the Azure DevOps REST API to evaluate the specified permissions.

.PARAMETER Organization
    The name or ID of the Azure DevOps organization.

.PARAMETER SecurityNamespaceId
    The ID of the security namespace to evaluate permissions against.

.PARAMETER Evaluations
    An array of PermissionEvaluation objects representing the permissions to evaluate.

.PARAMETER PersonalAccessToken
    The personal access token to authenticate the request. Optional.

.PARAMETER AlwaysAllowAdministrators
    Specifies whether to always allow administrators. Default is $false.

.EXAMPLE
    $evaluations = @(
        [PermissionEvaluation]::new("Project", "MyProject", "Contributor"),
        [PermissionEvaluation]::new("Repository", "MyRepo", "Reader")
    )
    Test-AzDevOpsBatchPermissions -Organization "MyOrg" -SecurityNamespaceId "MyNamespace" -Evaluations $evaluations

.NOTES
    This function requires the Azure DevOps PowerShell module.
    Make sure you have installed the module before using this function.
#>

function Test-AzDevOpsBatchPermissions {
    [CmdletBinding()]
    param (
        # The name or ID of the Azure DevOps organization
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        # The ID of the security namespace to evaluate permissions against
        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespaceId,

        # An array of PermissionEvaluation objects representing the permissions to evaluate
        [Parameter(Mandatory = $true)]
        [PermissionEvaluation[]]$Evaluations,

        # The personal access token to authenticate the request
        [Parameter()]
        [string]$PersonalAccessToken,

        # Specifies whether to always allow administrators
        [Parameter()]
        [bool]$AlwaysAllowAdministrators = $false
    )

    # Write a verbose message to the console
    Write-Verbose "[Test-AzDevOpsBatchPermissions] Checking batch permissions for user."

    $params = @{
        Method = 'Post'
        Uri = "https://dev.azure.com/{0}/_apis/permissionsbatch?api-version=7.2-preview.1" -f $Organization
        Body = @{
            alwaysallowadministrators = $AlwaysAllowAdministrators
            evaluations = $Evaluations
        } | ConvertTo-Json
        Headers = @{
            Authorization=("Basic {0}" -f $base64AuthInfo)
        }
    }

    # If a personal access token is provided, add it to the headers
    if ($PersonalAccessToken) {
        $param.Headers.Authorization = "Basic {0}" -f (ConvertTo-Base64String -InputObject ":$($PersonalAccessToken)")
    }

    try {
        $response = Invoke-AzDevOpsApiRestMethod @params
        return $response.evaluations
    } catch {
        Throw "Error: $($_.Exception.Message)"
    }

}
