Function Set-AzPersonalAccessToken {
    [CmdletBinding(DefaultParameterSetName = 'PersonalAccessToken')]
    param (
        # Organization Name
        [Parameter(Mandatory, ParameterSetName = 'PersonalAccessToken')]
        [Parameter(Mandatory, ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Alias('OrgName')]
        [String]
        $OrganizationName,

        # Personal Access Token
        [Parameter(Mandatory, ParameterSetName = 'PersonalAccessToken')]
        [Alias("PAT")]
        [String]
        $PersonalAccessToken,

        # Secure String Personal Access Token
        [Parameter(Mandatory, ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Alias("SecureStringPAT")]
        [SecureString]
        $SecureStringPersonalAccessToken,

        # Verify the Connection
        [Parameter(ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Parameter(ParameterSetName = 'PersonalAccessToken')]
        [Switch]
        $Verify
    )

    Write-Verbose "[Set-PersonalAccessToken] Setting the Personal Access Token for the organization $OrganizationName."

    # If a SecureString Personal Access Token is provided, parse it and set as the Token
    if ($SecureStringPersonalAccessToken) {
        $Token = New-PersonalAccessToken -SecureStringPersonalAccessToken $SecureStringPersonalAccessToken
    } elseif ($PersonalAccessToken) {
        # TypeCast the response to a PersonalAccessToken object
        $Token = New-PersonalAccessToken -PersonalAccessToken $PersonalAccessToken
    } else {
        throw "Error. A Personal Access Token or SecureString Personal Access Token must be provided."
    }

    #
    # Return the token if the verify switch is not set
    if (-not($verify)) { return $Token }

    Write-Verbose "[Set-PersonalAccessToken] Verifying the connection to the Azure DevOps API."

    # Test the Connection
    if (-not(Test-AzToken $Token)) { throw "Error. Failed to call the Azure DevOps API." }

    Write-Verbose "[Set-PersonalAccessToken] Connection Verified."

    # Return the AccessToken
    return ($Token)

}
