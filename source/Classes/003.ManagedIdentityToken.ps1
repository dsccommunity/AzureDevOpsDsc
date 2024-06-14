

Class ManagedIdentityToken : AuthenticationToken {

    hidden [SecureString]$access_token
    [DateTime]$expires_on
    [Int]$expires_in
    [String]$resource
    [String]$token_type

    # Constructor
    ManagedIdentityToken([PSCustomObject]$ManagedIdentityTokenObj) {

        $this.tokenType = [TokenType]::ManagedIdentity

        # Validate that ManagedIdentityTokenObj is a HashTable and Contains the correct keys
        if (-not $this.isValid($ManagedIdentityTokenObj)) { throw "[ManagedIdentityToken] The ManagedIdentityTokenObj is not valid." }

        $epochStart = [datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)

        # Set the properties of the class
        $this.access_token  = $ManagedIdentityTokenObj.access_token | ConvertTo-SecureString -AsPlainText -Force
        $this.expires_on    = $epochStart.AddSeconds($ManagedIdentityTokenObj.expires_on)
        $this.expires_in    = $ManagedIdentityTokenObj.expires_in
        $this.resource      = $ManagedIdentityTokenObj.resource
        $this.token_type    = $ManagedIdentityTokenObj.token_type

    }

    # Function to validate the ManagedIdentityTokenObj
    Hidden [Bool]isValid($ManagedIdentityTokenObj) {

        # Write-Verbose
        Write-Verbose "[ManagedIdentityToken] Validating the ManagedIdentityTokenObj."

        # Assuming these are the keys we expect in the hashtable
        $expectedKeys = @('access_token', 'expires_on', 'expires_in', 'resource', 'token_type')

        # Check if all expected keys exist in the hashtable
        foreach ($key in $expectedKeys) {
            if (-not $ManagedIdentityTokenObj."$key") {
                Write-Verbose "[ManagedIdentityToken] The hashtable does not contain the expected property: $key"
                return $false
            }
        }

        # If all checks pass, return true
        Write-Verbose "[ManagedIdentityToken] The hashtable is valid and contains all the expected keys."
        return $true
    }

    [Bool]isExpired() {
        # Remove 10 seconds from the expires_on time to account for clock skew.
        if ($this.expires_on.AddSeconds(-10) -lt (Get-Date)) { return $true }
        return $false
    }

    # Return the access token
    [String] Get() {

        # Verbose output
        Write-Verbose "[ManagedIdentityToken] Getting the access token:"
        Write-Verbose "[ManagedIdentityToken] Ensuring that the calling function is allowed to call the Get() method."

        # Test the caller
        $this.TestCaller()

        Write-Verbose "[ManagedIdentityToken] Token Retrival Successful."

        # Return the access token
        return ($this.ConvertFromSecureString($this.access_token))

    }

}

# Function to create a new ManagedIdentityToken object
Function global:New-ManagedIdentityToken ([PSCustomObject]$ManagedIdentityTokenObj) {

    # Verbose output
    Write-Verbose "[ManagedIdentityToken] Creating a new ManagedIdentityToken object."

    # Create and return a new ManagedIdentityToken object
    return [ManagedIdentityToken]::New($ManagedIdentityTokenObj)

}
