<#
.SYNOPSIS
Creates a new Azure Managed Identity.

.DESCRIPTION
The New-AzDoAuthenticationProvider function creates a new Azure Managed Identity for use in Azure DevOps DSC.

.PARAMETER OrganizationName
Specifies the name of the organization associated with the Azure Managed Identity.

.EXAMPLE
New-AzDoAuthenticationProvider -OrganizationName "Contoso"

This example creates a new Azure Managed Identity for the organization named "Contoso".

#>
Function New-AzDoAuthenticationProvider {

    [CmdletBinding(DefaultParameterSetName = 'PersonalAccessToken')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'PersonalAccessToken')]
        [Parameter(Mandatory, ParameterSetName = 'ManagedIdentity')]
        [Alias('OrgName')]
        [String]
        $OrganizationName,

        [Parameter(Mandatory, ParameterSetName = 'PersonalAccessToken')]
        [Alias('PersonalAccessToken')]
        [String]
        $PersonalAccessToken,

        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Switch]
        $useManagedIdentity
    )


    $Global:DSCAZDO_OrganizationName = $OrganizationName
    $Global:DSCAZDO_AuthenticationToken = $null


    #
    # If the parameterset is PersonalAccessToken

    if ($PSCmdlet.ParameterSetName -eq 'PersonalAccessToken') {
        Write-Verbose "[New-AzDoAuthenticationProvider] Creating a new Personal Access Token with OrganizationName $OrganizationName."
        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_AuthenticationToken = Get-AzManagedIdentityToken -OrganizationName $OrganizationName -PersonalAccessToken $PersonalAccessToken
        return
    }

    #
    # If the parameterset is ManagedIdentity

    if ($PSCmdlet.ParameterSetName -eq 'ManagedIdentity') {
        Write-Verbose "[New-AzDoAuthenticationProvider] Creating a new Azure Managed Identity with OrganizationName $OrganizationName."
        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_AuthenticationToken = Get-AzManagedIdentityToken -OrganizationName $OrganizationName -Verify
        return
    }

}
