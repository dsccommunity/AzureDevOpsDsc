

<#
.SYNOPSIS
Represents a Personal Access Token (PAT) used for authentication.

.DESCRIPTION
The `PersonalAccessToken` class inherits from the `AuthenticationToken` class and provides methods to handle Personal Access Tokens.
It includes constructors for initializing the token using a plain text string or a secure string, and a method to check if the token is expired.

.CONSTRUCTORS
PersonalAccessToken([String]$PersonalAccessToken)
    Initializes a new instance of the `PersonalAccessToken` class using a plain text string.

PersonalAccessToken([SecureString]$SecureStringPersonalAccessToken)
    Initializes a new instance of the `PersonalAccessToken` class using a secure string.

.METHODS
[Bool]isExpired()
    Checks if the Personal Access Token is expired. Always returns $false as Personal Access Tokens do not expire.

.NOTES
The `PersonalAccessToken` class sets the token type to `PersonalAccessToken` and converts the plain text token to a secure string if necessary.
#>
class PersonalAccessToken : AuthenticationToken
{

    PersonalAccessToken([String]$PersonalAccessToken)
    {
        $this.tokenType = [TokenType]::PersonalAccessToken
        $this.access_token = ConvertTo-Base64String -InputObject ":$($PersonalAccessToken)" | ConvertTo-SecureString -AsPlainText -Force
    }

    PersonalAccessToken([SecureString]$SecureStringPersonalAccessToken)
    {
        $this.tokenType = [TokenType]::PersonalAccessToken
        $this.access_token = $SecureStringPersonalAccessToken
    }

    [Bool]isExpired() {
        # Personal Access Tokens do not expire.
        return $false
    }

}

<#
Creates a new PersonalAccessToken object.

.DESCRIPTION
This function creates a new PersonalAccessToken object using either a plain text personal access token or a secure string personal access token.

.PARAMETER PersonalAccessToken
A plain text personal access token.

.PARAMETER SecureStringPersonalAccessToken
A secure string personal access token.

.RETURNS
Returns a new instance of the PersonalAccessToken object.

.EXAMPLE
$token = New-PersonalAccessToken -PersonalAccessToken "your-token-here"
Creates a new PersonalAccessToken object using a plain text token.

.EXAMPLE
$secureToken = ConvertTo-SecureString "your-token-here" -AsPlainText -Force
$token = New-PersonalAccessToken -SecureStringPersonalAccessToken $secureToken
Creates a new PersonalAccessToken object using a secure string token.

.NOTES
If neither a plain text personal access token nor a secure string personal access token is provided, an error is thrown.
#>

Function global:New-PersonalAccessToken ([String]$PersonalAccessToken, [SecureString]$SecureStringPersonalAccessToken)
{

    # Verbose output
    Write-Verbose "[PersonalAccessToken] Creating a new ManagedIdentityToken object."

    if ($PersonalAccessToken)
    {
        # Create a new PersonalAccessToken object
        return [PersonalAccessToken]::New($PersonalAccessToken)
    }
    elseif ($SecureStringPersonalAccessToken)
    {
        # Create a new PersonalAccessToken object
        return [PersonalAccessToken]::New($SecureStringPersonalAccessToken)
    }
    else
    {
        throw "Error. A Personal Access Token or SecureString Personal Access Token must be provided."
    }

}
