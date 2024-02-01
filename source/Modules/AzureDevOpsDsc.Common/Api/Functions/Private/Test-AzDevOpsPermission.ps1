<#
.SYNOPSIS
Checks if a user has a specific permission in Azure DevOps.

.DESCRIPTION
The Test-AzDevOpsPermission function checks if a user has a specific permission in Azure DevOps by making a REST API call to the Azure DevOps API.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER ProjectId
The ID of the Azure DevOps project.

.PARAMETER Token
The personal access token used for authentication.

.PARAMETER NamespaceId
The ID of the permission namespace.

.PARAMETER TokenId
The ID of the permission token.

.PARAMETER Permissions
The permission level to check.

.PARAMETER AlwaysAllowAdministrators
Specifies whether to always allow administrators.

.EXAMPLE
Test-AzDevOpsPermission -Organization "MyOrg" -ProjectId "MyProject" -Token "MyToken" -NamespaceId 1 -TokenId 2 -Permissions 16 -AlwaysAllowAdministrators $true

This example checks if the user specified by the personal access token "MyToken" has write permission (16) in the permission namespace with ID 1 and token ID 2 in the Azure DevOps organization "MyOrg" and project "MyProject". It always allows administrators.

#>
function Test-AzDevOpsPermission {
    [CmdletBinding()]
    param (
        # The name of the Azure DevOps organization
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        # The ID of the Azure DevOps project
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        # The personal access token used for authentication
        [Parameter(Mandatory = $false)]
        [string]$PersonalAccessToken,

        # The ID of the permission namespace
        [Parameter(Mandatory = $true)]
        [int]$NamespaceId,

        # The ID of the permission token
        [Parameter(Mandatory = $true)]
        [int]$ACLTokenId,

        # The permission level to check
        [Parameter(Mandatory = $true)]
        [int]$Permissions,

        # Specifies whether to always allow administrators
        [Parameter(Mandatory)]
        [bool]$AlwaysAllowAdministrators=$true
    )

    # Write a verbose message to the console
    Write-Verbose "[Test-AzDevOpsPermission] Checking permissions for user '$($ACLTokenId)' in organization '$Organization' and project '$ProjectId'"

    $params = @{
        Uri = "https://dev.azure.com/{0}/_apis/permissions/{1}/{2}?permissions={3}&alwaysAllowAdministrators={4}&api-version=7.2-preview.1" -f $Organization, $NamespaceId, $ACLTokenId, $Permissions, $AlwaysAllowAdministrators
        Method = 'Get'
        Headers = @{}
    }

    # If a personal access token is provided, add it to the headers
    if ($PersonalAccessToken) {
        $param.Headers.Authorization = "Basic {0}" -f (ConvertTo-Base64String -InputObject ":$($PersonalAccessToken)")
    }

    try {
        # Invoke the REST method using the provided parameters
        $response = Invoke-RestMethod @params

        # Return the 'value' property from the response object.
        # This assumes that the result is an object or a hashtable that contains a 'value' key.
        return $response.value
    }
    catch
    {
        Throw "Failed to check permissions: $_"
    }

}
