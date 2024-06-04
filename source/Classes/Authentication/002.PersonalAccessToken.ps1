

Class PersonalAccessToken : AuthenticationToken {

    hidden [SecureString]$access_token

    PersonalAccessToken([String]$PersonalAccessToken) {
        $this.tokenType = [TokenType].PersonalAccessToken
        $this.access_token = ConvertTo-Base64String -InputObject ":$($PersonalAccessToken)" | ConvertTo-SecureString -AsPlainText -Force
    }

    [Bool]isExpired() {
        # Personal Access Tokens do not expire.
        return $false
    }


}

# Function to create a new PersonalAccessToken object
Function global:New-PersonalAccessToken ([String]$PersonalAccessToken) {

    # Verbose output
    Write-Verbose "[PersonalAccessToken] Creating a new ManagedIdentityToken object."

    # Create and return a new ManagedIdentityToken object
    return [PersonalAccessToken]::New($PersonalAccessToken)

}
