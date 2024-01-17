class AzManagedIdentity
{
    [Alias('OrgName')]
    [System.String]
    $AZDOOrganizationName

    AzManagedIdentity([String]$AZDOOrganizationName) {
        # Test if the Global Var's Exist $Global:DSCAZDO_OrganizationName
        if ($null -eq $Global:DSCAZDO_OrganizationName) { }
        $this.AZDOOrganizationName = 
        $Global:DSCAZDO_OrganizationName = 
    }

    AzManagedIdentity() {
        # Test if the Global Var's Exist $Global:DSCAZDO_OrganizationName
        if ($null -eq $Global:DSCAZDO_OrganizationName) { }
        $this.AZDOOrganizationName = $Global:DSCAZDO_OrganizationName
        # Test if the Token Global Object Exists $Global:DSCAZDO_Pat
        if ($null -eq $Global:DSCAZDO_Pat) { }
        

    }

    hidden [PSCustomObject]InvokeRestMethod($Uri, $Method, $Headers, $Body = $null) {

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

        # Extract the Access Token from the response
        $accessToken = $response.access_token

        # Return the token if the verify switch is not set
        if (-not($verify)) { return $response }

        # Test the Connection
        if (-not($this.TestAZDOConnection($this.OrganizationName, $accessToken))) { throw $LocalizedData.Error_Azure_API_Call_Generic }
                
        # Return the AccessToken
        return ($response)

    }

    hidden [bool]TestAZDOConnection([String]$AZDOOrganizationName, [SecureString]$Token) {

            # Define the Azure DevOps REST API endpoint to get the list of projects
            $AZDOProjectUrl = $LocalizedData.Global_Url_AZDO_Project -f $AZDOOrganizationName
            $FormattedUrl = "{0}?{1}" -f $AZDOProjectUrl, $LocalizedData.Global_API_Azure_DevOps_Version

            $headers = @{
                Authorization ="Bearer $this.Pat"
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
    
    hidden [String]ConvertFromSecureString([SecureString]$SecureString) {
        # Convert a SecureString to a String
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $String = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        return $String
    }

    [String]GetAccessToken() {

        # Check to see if the token requires refreshing
        if ($this.Pat -and $this.TestAZDOConnection($this.OrganizationName, $this.Pat)) { return $this.Pat }

        # Get the access token from the Managed Identity
        $ManagedIdentityToken = $this.GetManagedIdentityToken($true)

        # Return the access token
        return $ManagedIdentityToken.access_token

    }

}