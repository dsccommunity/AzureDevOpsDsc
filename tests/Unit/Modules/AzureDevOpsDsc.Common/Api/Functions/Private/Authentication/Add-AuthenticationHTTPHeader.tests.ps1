Describe "Add-AuthenticationHTTPHeader" {

    BeforeEach {
        # Reset the global variables before each test
        $Global:DSCAZDO_AuthenticationToken = $null
        $Global:DSCAZDO_OrganizationName = "TestOrg"
    }

    It "Throws an error when the token is null" {
        $Global:DSCAZDO_AuthenticationToken = $null
        { Add-AuthenticationHTTPHeader } | Should -Throw "[Add-AuthenticationHTTPHeader] Error. The authentication token is null. Please ensure that the authentication token is set."
    }

    It "Returns header for PersonalAccessToken" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'PersonalAccessToken'
            Get = { return "dummyPAT" }
        }
        $result = Add-AuthenticationHTTPHeader
        $result | Should -Be "Authorization: Basic dummyPAT"
    }

    It "Returns header for ManagedIdentity when token is not expired" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'ManagedIdentity'
            Get = { return "dummyMIToken" }
            isExpired = { return $false }
        }
        $result = Add-AuthenticationHTTPHeader
        $result | Should -Be "Bearer dummyMIToken"
    }

    It "Updates and returns header for ManagedIdentity when token is expired" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'ManagedIdentity'
            Get = { return "expiredMIToken" }
            isExpired = { return $true }
        }

        # Mock Update-AzManagedIdentityToken cmdlet
        Mock Update-AzManagedIdentityToken {
            return @{
                tokenType = 'ManagedIdentity'
                Get = { return "newMIToken" }
                isExpired = { return $false }
            }
        }

        $result = Add-AuthenticationHTTPHeader
        $result | Should -Be "Bearer newMIToken"
    }

    It "Throws an error for unsupported token type" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'UnsupportedToken'
            Get = { return "dummyToken" }
        }
        { Add-AuthenticationHTTPHeader } | Should -Throw "[Add-AuthenticationHTTPHeader] Error. The authentication token type is not supported."
    }
}
