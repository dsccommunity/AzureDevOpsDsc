Function Get-MIToken {
    [CmdletBinding()]
    param (
        # Organization Name
        [Parameter(Mandatory = $true)]
        [String]
        $OrganizationName
    )

    Write-Verbose "[Get-MIToken] Getting the managed identity token for the organization $OrganizationName."

    # Obtain the access token from Azure AD using the Managed Identity

    $ManagedIdentityParams = @{
        # Define the Azure instance metadata endpoint to get the access token
        Uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=499b84ac-1321-427f-aa17-267ca6975798"
        Method = 'Get'
        HttpHeaders = @{ Metadata="true" }
        ContentType = 'Application/json'
    }

    # Dertimine if the machine is an arc machine
    if ($env:IDENTITY_ENDPOINT)
    {

        Write-Verbose "[Get-MIToken] The machine is an Azure Arc machine. The Uri needs to be updated to $($env:IDENTITY_ENDPOINT):"
        $ManagedIdentityParams.Uri = '{0}?api-version=2020-06-01&resource=499b84ac-1321-427f-aa17-267ca6975798' -f $env:IDENTITY_ENDPOINT
        $ManagedIdentityParams.AzureArcAuthentication = $true

    }

    Write-Verbose "[Get-MIToken] Invoking the Azure Instance Metadata Service to get the access token."

    # Invoke the RestAPI
    try
    {
        $response = Invoke-APIRestMethod @ManagedIdentityParams
    }
    catch
    {
        # If there is an error it could be because it's an arc machine, and we need to use the secret file:
        $wwwAuthHeader = $_.Exception.Response.Headers.WwwAuthenticate
        if ($wwwAuthHeader -notmatch "Basic realm=.+")
        {
            Throw ('[Get-MIToken] {0}' -f $_)
        }

        Write-Verbose "[Get-MIToken] Managed Identity Token Retrival Failed. Retrying with secret file."

        # Extract the secret file path from the WWW-Authenticate header
        $secretFile = ($wwwAuthHeader -split "Basic realm=")[1]
        # Read the secret file to get the token
        $token = Get-Content -LiteralPath $secretFile -Raw
        # Add the token to the headers
        $ManagedIdentityParams.HttpHeaders.Authorization = "Basic $token"

        # Retry the request. Silently continue to suppress the error message, since we will handle it below.
        $response = Invoke-APIRestMethod @ManagedIdentityParams -ErrorAction SilentlyContinue
    }

    # Test the response
    if ($null -eq $response.access_token)
    {
        throw "Error. Access token not returned from Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available."
    }

    # Return the token if the verify switch is not set
    return @{
        tokenType = 'ManagedIdentity'
        token = $response.access_token
    }

}
