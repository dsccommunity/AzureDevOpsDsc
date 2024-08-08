Function Get-MIToken {
    [CmdletBinding()]
    param (
        # Organization Name
        [Parameter(Mandatory)]
        [String]
        $OrganizationName
    )

    Write-Verbose "[Get-AzManagedIdentityToken] Getting the managed identity token for the organization $OrganizationName."

    # Obtain the access token from Azure AD using the Managed Identity

    $ManagedIdentityParams = @{
        # Define the Azure instance metadata endpoint to get the access token
        Uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=499b84ac-1321-427f-aa17-267ca6975798"
        Method = 'Get'
        Headers = @{ Metadata="true" }
        ContentType = 'Application/json'
    }

    Write-Verbose "[Get-AzManagedIdentityToken] Invoking the Azure Instance Metadata Service to get the access token."

    # Invoke the RestAPI
    try { $response = Invoke-RestMethod @ManagedIdentityParams } catch { Throw $_ }
    # Test the response
    if ($null -eq $response.access_token) { throw "Error. Access token not returned from Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available." }

    # Return the token if the verify switch is not set
    return $response.access_token

}
