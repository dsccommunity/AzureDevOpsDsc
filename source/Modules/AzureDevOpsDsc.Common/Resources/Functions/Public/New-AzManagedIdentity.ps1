<#
.SYNOPSIS
Creates a new Azure Managed Identity.

.DESCRIPTION
The New-AzManagedIdentity function creates a new Azure Managed Identity for use in Azure DevOps DSC.

.PARAMETER OrganizationName
Specifies the name of the organization associated with the Azure Managed Identity.

.EXAMPLE
New-AzManagedIdentity -OrganizationName "Contoso"

This example creates a new Azure Managed Identity for the organization named "Contoso".

#>
Function New-AzManagedIdentity {

    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias('OrgName')]
        [String]
        $OrganizationName
    )

    Write-Verbose "[New-AzManagedIdentity] Creating a new Azure Managed Identity with OrganizationName $OrganizationName."

    $Global:DSCAZDO_OrganizationName = $OrganizationName
    $Global:DSCAZDO_ManagedIdentityToken = $null

    # If the Token is not Valid. Get a new Token.
    $Global:DSCAZDO_ManagedIdentityToken = Get-AzManagedIdentityToken -OrganizationName $OrganizationName -Verify

}
