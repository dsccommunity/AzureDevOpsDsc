Function Add-AuthenticationHTTPHeader {

    # Dertimine the type of token.

    $headerValue = ""

    switch ($Global:DSCAZDO_AuthenticationToken.tokenType) {

        # If the token is null
        {[String]::IsNullOrEmpty($_)} {
            throw "[Add-AuthenticationHTTPHeader] Error. The authentication token is null. Please ensure that the authentication token is set."
        }
        {$_ -eq 'PersonalAccessToken'} {

            #
            # Personal Access Token

            # Add the Personal Access Token to the header
            $headerValue = "Authorization: Basic {0}" -f $Global:DSCAZDO_AuthenticationToken.Get()
            break
        }
        {$_ -eq 'ManagedIdentity'} {

            #
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
