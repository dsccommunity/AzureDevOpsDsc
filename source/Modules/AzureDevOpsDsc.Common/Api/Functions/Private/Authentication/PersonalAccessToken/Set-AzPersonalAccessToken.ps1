Function Set-AzPersonalAccessToken {
    [CmdletBinding()]
    param (
        # Organization Name
        [Parameter(Mandatory)]
        [String]
        $OrganizationName,

        # Personal Access Token
        [Parameter(Mandatory)]
        [Alias("PAT")]
        [String]
        $PersonalAccessToken,

        # Verify the Connection
        [Parameter()]
        [Switch]
        $Verify
    )

    Write-Verbose "[Set-PersonalAccessToken] Setting the Personal Access Token for the organization $OrganizationName."

    # TypeCast the response to a PersonalAccessToken object
    $Token = New-PersonalAccessToken $PersonalAccessToken

    # Return the token if the verify switch is not set
    if (-not($verify)) { return $Token }

    Write-Verbose "[Set-PersonalAccessToken] Verifying the connection to the Azure DevOps API."

    # Test the Connection
    if (-not(Test-Token $Token)) { throw "Error. Failed to call the Azure DevOps API." }

    Write-Verbose "[Set-PersonalAccessToken] Connection Verified."

    # Return the AccessToken
    return ($Token)

}
