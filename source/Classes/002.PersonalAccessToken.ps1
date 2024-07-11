

Class PersonalAccessToken : AuthenticationToken {



    PersonalAccessToken([String]$PersonalAccessToken) {
        $this.tokenType = [TokenType]::PersonalAccessToken
        $this.access_token = ConvertTo-Base64String -InputObject ":$($PersonalAccessToken)" | ConvertTo-SecureString -AsPlainText -Force
    }

    PersonalAccessToken([SecureString]$SecureStringPersonalAccessToken) {
        $this.tokenType = [TokenType]::PersonalAccessToken
        $this.access_token = $SecureStringPersonalAccessToken
    }

    [Bool]isExpired() {
        # Personal Access Tokens do not expire.
        return $false
    }


}

# Function to create a new PersonalAccessToken object
Function global:New-PersonalAccessToken ([String]$PersonalAccessToken, [SecureString]$SecureStringPersonalAccessToken) {

    # Verbose output
    Write-Verbose "[PersonalAccessToken] Creating a new ManagedIdentityToken object."

    if ($PersonalAccessToken) {
        # Create a new PersonalAccessToken object
        return [PersonalAccessToken]::New($PersonalAccessToken)
    } elseif ($SecureStringPersonalAccessToken) {
        # Create a new PersonalAccessToken object
        return [PersonalAccessToken]::New($SecureStringPersonalAccessToken)
    } else {
        throw "Error. A Personal Access Token or SecureString Personal Access Token must be provided."
    }

}
