<#
.SYNOPSIS
Updates the Azure Managed Identity.

.DESCRIPTION
This function updates the Azure Managed Identity by refreshing the token.

.PARAMETER OrganizationName
The name of the organization associated with the Managed Identity.

.EXAMPLE
Update-AzManagedIdentity -OrganizationName "Contoso"

This example updates the Azure Managed Identity for the organization named "Contoso".

#>

Function Update-AzManagedIdentity {

    # Test if the Global Var's Exist $Global:DSCAZDO_OrganizationName
    if ($null -eq $Global:DSCAZDO_OrganizationName) {
        Throw "[Update-AzManagedIdentity] Organization Name is not set. Please run 'New-AzManagedIdentity -OrganizationName <OrganizationName>'"
    }

    # Clear the existing token.
    $Global:DSCAZDO_AuthenticationToken = $null

    # Refresh the Token.
    $Global:DSCAZDO_AuthenticationToken = Get-AzManagedIdentityToken -OrganizationName $Global:DSCAZDO_OrganizationName

}
