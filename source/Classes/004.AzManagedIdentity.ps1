class AzManagedIdentity
{
    [Alias('OrgName')]
    [System.String]
    $AZDOOrganizationName

    AzManagedIdentity([String]$AZDOOrganizationName) {

        # Test if the Global Var's Exist $Global:DSCAZDO_OrganizationName
        $this.AZDOOrganizationName = $AZDOOrganizationName
        $Global:DSCAZDO_OrganizationName = $AZDOOrganizationName
        $Global:DSCAZDO_ManagedIdentityToken = $this.GetManagedIdentityToken($true)

        # Attempt to get the Managed Identity Token
        try { $this.AssumeIdentity() } catch {
            Write-Warning "Warning: Errors were encountered while attempting to get the Managed Identity Token. Use AssumeIdentity() to attempt to get the token again."
        }

    }

    AzManagedIdentity() {
        # Test if the Global Var's Exist $Global:DSCAZDO_OrganizationName
        if ($null -eq $Global:DSCAZDO_OrganizationName) {
            Throw "Organization Name is not set. Please instanciate the AzManagedIdentity Class with the Organization Name."
        }
        $this.AZDOOrganizationName = $Global:DSCAZDO_OrganizationName
        # Test if the Token Global Object Exists $Global:DSCAZDO_Pat
        if ($null -eq $Global:DSCAZDO_Pat) {
            Write-Error "Managed Identity Token is not set. Please instanciate the AzManagedIdentity Class with the Organization Name. Or use the GetToken() Method"
        }

    }

    hidden [PSCustomObject]InvokeRestMethod($Uri, $Method, $Headers, $Body = $null) {

        $responseHeaders = $null

        # Write a script to invoke the REST method and return the response
        $params = @{
            Uri     = $Uri
            Method  = $Method
            Headers = $Headers
            Body    = $Body
            ResponseHeadersVariable = 'responseHeaders'
        }

        # Remove Parameters that are null
        if ($null -eq $params.Body) { $params.Remove('Body') }
        if ($null -eq $params.Headers) { $params.Remove('Headers') }

        # Invoke the REST method
        try {

            $result = Invoke-WebRequest @params
            $response = @{
                error = $false
                Content = $result.content | ConvertFrom-Json
                StatusCode = $result.StatusCode
                ResponseHeaders = $responseHeaders
            }

        } catch {

            # Write a response
            $response = [PSCustomObject]@{
                error = $true
                StatusCode = $_.Exception.StatusCode
                Message = $_.Exception.Message
            }

            # Write an Error
            Write-Error ( $LocalizedData.Error_ManagedIdentity_RestApiCallFailed -f $_.Exception.Message )

        }

        # Return the response
        return $response

    }

    hidden [HashTable]GetManagedIdentityToken([Switch]$verify = $false) {

        # Obtain the access token from Azure AD using the Managed Identity

        $ManagedIdentityParams = @{
            # Define the Azure instance metadata endpoint to get the access token
            Uri = $LocalizedData.Global_Url_AzureInstanceMetadataUrl -f $LocalizedData.Global_AzureDevOps_Resource_Id
            Method = 'Get'
            Headers = @{Metadata="true"}
            'Context-Type' = 'Application/json'
        }

        # Invoke the RestAPI
        $response = $this.InvokeRestMethod($ManagedIdentityParams.Uri, $ManagedIdentityParams.Method, $ManagedIdentityParams.Headers)

        # If the response is an error
        if ($response.error) { throw $response.Message }
        # If the access token is not returned
        if ($null -eq $response.Content.access_token) { throw $LocalizedData.Error_Azure_Instance_Metadata_Service_Missing_Token }

        # TypeCast the response to a ManagedIdentityToken object
        $ManagedIdentity = [ManagedIdentityToken]::New($response.Content)
        # Null the response
        $null = $response

        # Return the token if the verify switch is not set
        if (-not($verify)) { return $ManagedIdentity }

        # Test the Connection
        if (-not($this.TestAZDOConnection($this.OrganizationName, $ManagedIdentity))) { throw $LocalizedData.Error_Azure_API_Call_Generic }

        # Return the AccessToken
        return ($ManagedIdentity)

    }

    hidden [bool]TestAZDOConnection([String]$AZDOOrganizationName, [ManagedIdentityToken]$ManagedIdentityToken) {

            # Define the Azure DevOps REST API endpoint to get the list of projects
            $AZDOProjectUrl = $LocalizedData.Global_Url_AZDO_Project -f $AZDOOrganizationName
            $FormattedUrl = "{0}?{1}" -f $AZDOProjectUrl, $LocalizedData.Global_API_Azure_DevOps_Version

            $headers = @{
                Authorization ="Bearer {0}" -f $ManagedIdentityToken.Get()
                'Context-Type' = 'Application/json'
            }

            $response = $false

            # Call the Azure DevOps REST API with the Bearer token
            try {
                $projectListResponse = $this.InvokeRestMethod($FormattedUrl, 'Get', $headers)
            } catch {
                return $false
            }

            # If the response is an error
            if ($projectListResponse.error) { Write-Error $projectListResponse.Message } else { $response = $true }

            # If the response is not an error
            return $response

    }

    [Bool] isTokenValid() {

        # If the TokenObject Dosn't Exist. Return False.
        if ($null -eq $Global:DSCAZDO_ManagedIdentityToken) { return $false }

        # Ensure that $Global:DSCAZDO_ManagedIdentityToken is a ManagedIdentityToken Object
        if ($Global:DSCAZDO_ManagedIdentityToken -isnot [ManagedIdentityToken]) { return $false }

        # Ensure that token has not exipred
        if ($Global:DSCAZDO_ManagedIdentityToken.isExpired()) { return $false }

        return $true

    }

    [void] AssumeIdentity() {

        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_ManagedIdentityToken = $this.GetManagedIdentityToken($true)

    }

}
