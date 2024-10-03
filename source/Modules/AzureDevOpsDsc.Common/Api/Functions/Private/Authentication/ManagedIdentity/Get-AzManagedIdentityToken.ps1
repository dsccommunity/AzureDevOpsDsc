<#
.SYNOPSIS
Obtains a managed identity token from Azure AD.

.DESCRIPTION
The Get-AzManagedIdentityToken function is used to obtain an access token from Azure AD using a managed identity. It can only be called from the New-AzManagedIdentity or Update-AzManagedIdentity functions.

.PARAMETER OrganizationName
Specifies the name of the organization.

.PARAMETER Verify
Specifies whether to verify the connection. If this switch is not set, the function returns the managed identity token. If the switch is set, the function tests the connection and returns the access token.

.EXAMPLE
Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
Obtains the access token for the managed identity associated with the organization "Contoso" and verifies the connection.

.NOTES
This function does not require the Azure PowerShell module.
#>

Function Get-AzManagedIdentityToken {
    [CmdletBinding()]
    param (
        # Organization Name
        [Parameter(Mandatory)]
        [String]
        $OrganizationName,

        # Verify the Connection
        [Parameter()]
        [Switch]
        $Verify
    )

    Write-Verbose "[Get-AzManagedIdentityToken] Getting the managed identity token for the organization $OrganizationName."

    # Obtain the access token from Azure AD using the Managed Identity

    $ManagedIdentityParams = @{
        # Define the Azure instance metadata endpoint to get the access token
        Uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=499b84ac-1321-427f-aa17-267ca6975798"
        Method = 'Get'
        Headers = @{ Metadata="true" }
        ContentType = 'Application/json'
        NoAuthentication = $true
        UseBasicParsing = $true
    }

    Write-Verbose "[Get-AzManagedIdentityToken] Invoking the Azure Instance Metadata Service to get the access token."

    # Invoke the RestAPI
    try {
        $response = Invoke-AzDevOpsApiRestMethod @ManagedIdentityParams
    } catch {

        # If there is an error it could be because it's an arc machine, and we need to use the secret file:
        $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
        if ($wwwAuthHeader -notmatch "Basic realm=.+")
        {
            Throw $_
        }

        Write-Verbose "[Get-AzManagedIdentityToken] Managed Identity Token Retrival Failed. Retrying with secret file."

        # Extract the secret file path from the WWW-Authenticate header
        $secretFile = ($wwwAuthHeader -split "Basic realm=")[1]
        # Read the secret file to get the token
        $token = Get-Content -LiteralPath $secretFile -Raw
        # Add the token to the headers
        $ManagedIdentityParams.Authorization = "Basic $token"

        # Retry the request. Silently continue to suppress the error message, since we will handle it below.
        $response = Invoke-AzDevOpsApiRestMethod @ManagedIdentityParams -ErrorAction SilentlyContinue

    }
    # Test the response
    if ($null -eq $response.access_token) { throw "Error. Access token not returned from Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available." }

    Write-Verbose "[Get-AzManagedIdentityToken] Managed Identity Token Retrival Successful."

    # TypeCast the response to a ManagedIdentityToken object
    $ManagedIdentity = New-ManagedIdentityToken $response
    # Null the response
    $null = $response

    # Return the token if the verify switch is not set
    if (-not($verify)) { return $ManagedIdentity }

    Write-Verbose "[Get-AzManagedIdentityToken] Verifying the connection to the Azure DevOps API."

    # Test the Connection
    if (-not(Test-AzToken $ManagedIdentity)) { throw "Error. Failed to call the Azure DevOps API." }

    Write-Verbose "[Get-AzManagedIdentityToken] Connection Verified."

    # Return the AccessToken
    return ($ManagedIdentity)

}
