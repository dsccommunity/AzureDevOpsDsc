<#
.SYNOPSIS
Adds the appropriate authentication HTTP header based on the type of authentication token.

.DESCRIPTION
The Add-AuthenticationHTTPHeader function determines the type of authentication token and adds the corresponding HTTP header.
It supports Personal Access Tokens and Managed Identity Tokens. If the token is null or the token type is not supported, an error is thrown.

.PARAMETER None
This function does not take any parameters.

.OUTPUTS
String
Returns the authentication HTTP header as a string.

.NOTES
The function relies on the global variables $Global:DSCAZDO_AuthenticationToken and $Global:DSCAZDO_OrganizationName.

.EXAMPLE
$header = Add-AuthenticationHTTPHeader
# Adds the appropriate authentication HTTP header and returns it as a string.
#>

Function Add-AuthenticationHTTPHeader
{
    # Dertimine the type of token.
    $headerValue = ""
    switch ($Global:DSCAZDO_AuthenticationToken.tokenType)
    {

        # If the token is null
        {[String]::IsNullOrEmpty($_)} {
            throw "[Add-AuthenticationHTTPHeader] Error. The authentication token is null. Please ensure that the authentication token is set."
        }
        {$_ -eq 'PersonalAccessToken'} {
            # Personal Access Token

            # Add the Personal Access Token to the header
            $headerValue = 'Authorization: Basic {0}' -f $Global:DSCAZDO_AuthenticationToken.Get()
            break
        }
        {$_ -eq 'ManagedIdentity'} {
            # Managed Identity Token
            Write-Verbose "[Add-AuthenticationHTTPHeader] Adding Managed Identity Token to the HTTP Headers."

            # Test if the Managed Identity Token has expired
            if ($Global:DSCAZDO_AuthenticationToken.isExpired())
            {
                Write-Verbose "[Add-AuthenticationHTTPHeader] Managed Identity Token has expired. Obtaining a new token."
                # If so, get a new token
                $Global:DSCAZDO_AuthenticationToken = Update-AzManagedIdentity -OrganizationName $Global:DSCAZDO_OrganizationName
            }

            # Add the Managed Identity Token to the header
            $headerValue = 'Bearer {0}' -f $Global:DSCAZDO_AuthenticationToken.Get()
            break

        }
        default {
            throw "[Add-AuthenticationHTTPHeader] Error. The authentication token type is not supported."
        }

    }

    Write-Verbose "[Add-AuthenticationHTTPHeader] Adding Header"

    # Return the header value
    return $headerValue

}
