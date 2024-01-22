Function New-AzManagedIdentity {

    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias('OrgName')]
        [String]
        $OrganizationName
    )

    $Global:DSCAZDO_OrganizationName = $OrganizationName
    $Global:DSCAZDO_ManagedIdentityToken = $null

    # If the Token is not Valid. Get a new Token.
    $Global:DSCAZDO_ManagedIdentityToken = Get-AzManagedIdentityToken -OrganizationName $OrganizationName -Verify

}

