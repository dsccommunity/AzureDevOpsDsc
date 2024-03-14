<#
.SYNOPSIS
    Tests the Azure Managed Identity token for accessing Azure DevOps REST API.

.DESCRIPTION
    The Test-AzManagedIdentityToken function is used to test the Azure Managed Identity token for accessing the Azure DevOps REST API.
    It calls the Azure DevOps REST API with the provided Managed Identity token and returns true if the token is valid, otherwise returns false.

.PARAMETER ManagedIdentity
    Specifies the Managed Identity token to be tested.

.EXAMPLE
    $token = Get-AzManagedIdentityToken -ResourceId 'https://management.azure.com'
    $isValid = Test-AzManagedIdentityToken -ManagedIdentity $token
    if ($isValid) {
        Write-Host "Token is valid."
    } else {
        Write-Host "Token is invalid."
    }
#>

Function Test-AzManagedIdentityToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Object]
        $ManagedIdentity
    )

    # Define the Azure DevOps REST API endpoint to get the list of projects
    $AZDOProjectUrl = "https://dev.azure.com/{0}/_apis/projects" -f $GLOBAL:DSCAZDO_OrganizationName
    $FormattedUrl = "{0}?api-version=7.2-preview.4" -f $AZDOProjectUrl

    $params = @{
        Uri = $FormattedUrl
        Method = 'Get'
        Headers = @{
            Authorization ="Bearer {0}" -f $ManagedIdentity.Get()
        }
    }

    # Call the Azure DevOps REST API with the Managed Identity Bearer token
    try {
        $null = Invoke-AzDevOpsApiRestMethod @params
    } catch {
        return $false
    }

    return $true

}
