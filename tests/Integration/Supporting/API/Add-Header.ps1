Function Add-Header {

    # Dertimine the type of token.

    $headerValue = ""

    switch ($Global:DSCAZDO_AuthenticationToken.tokenType)
    {

        # If the token is null
        {$null} {
            throw "[Add-Header] Error. The authentication token is null. Please ensure that the authentication token is set."
        }
        {$_ -eq 'PersonalAccessToken'} {

            #
            # Personal Access Token

            # Add the Personal Access Token to the header
            $headerValue = 'Authorization: Basic {0}' -f $Global:DSCAZDO_AuthenticationToken.Token
            break
        }
        {$_ -eq 'ManagedIdentity'} {

            # Add the Managed Identity Token to the header
            $headerValue = 'Bearer {0}' -f $Global:DSCAZDO_AuthenticationToken.Token
            break

        }
        default {
            throw "[Add-Header] Error. The authentication token type is not supported."
        }

    }

    Write-Verbose "[Add-Header] Adding Header"

    # Return the header value
    return $headerValue

}
