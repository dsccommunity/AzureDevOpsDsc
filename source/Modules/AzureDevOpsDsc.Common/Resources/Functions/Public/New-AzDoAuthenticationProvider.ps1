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
        # Organization Name
        [Parameter(Mandatory, ParameterSetName = 'PersonalAccessToken')]
        [Parameter(Mandatory, ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Parameter(Mandatory, ParameterSetName = 'ManagedIdentity')]
        [Alias('OrgName')]
        [String]
        $OrganizationName,

        # Personal Access Token
        [Parameter(Mandatory, ParameterSetName = 'PersonalAccessToken')]
        [Alias('PersonalAccessToken')]
        [String]
        $PersonalAccessToken,

        # SecureString Personal Access Token
        [Parameter(Mandatory, ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Alias('SecureStringPAT')]
        [SecureString]
        $SecureStringPersonalAccessToken,

        # Use Managed Identity
        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Switch]
        $useManagedIdentity,

        # Do not export the Token
        # Used by Resources that do not require the Token to be exported.
        [Parameter(ParameterSetName = 'PersonalAccessToken')]
        [Parameter(ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Switch]
        $NoExport

    )

    # Test if $ENV:AZDODSC_CACHE_DIRECTORY is set. If not, throw an error.
    if ($null -eq $ENV:AZDODSC_CACHE_DIRECTORY) {
        Throw "[New-AzDoAuthenticationProvider] The Environment Variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the Environment Variable 'AZDODSC_CACHE_DIRECTORY' to the Cache Directory."
    }

    # Set the Global Variables
    $Global:DSCAZDO_OrganizationName = $OrganizationName
    $Global:DSCAZDO_AuthenticationToken = $null

    #
    # If the parameterset is PersonalAccessToken
    if ($PSCmdlet.ParameterSetName -eq 'PersonalAccessToken') {
        Write-Verbose "[New-AzDoAuthenticationProvider] Creating a new Personal Access Token with OrganizationName $OrganizationName."
        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_AuthenticationToken = Set-AzPersonalAccessToken -PersonalAccessToken $PersonalAccessToken
    }
    #
    # If the parameterset is ManagedIdentity
    elseif ($PSCmdlet.ParameterSetName -eq 'ManagedIdentity') {
        Write-Verbose "[New-AzDoAuthenticationProvider] Creating a new Azure Managed Identity with OrganizationName $OrganizationName."
        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_AuthenticationToken = Get-AzManagedIdentityToken -OrganizationName $OrganizationName -Verify
        return
    }
    #
    # If the parameterset is SecureStringPersonalAccessToken
    elseif ($PSCmdlet.ParameterSetName -eq 'SecureStringPersonalAccessToken') {
        Write-Verbose "[New-AzDoAuthenticationProvider] Creating a new Personal Access Token with OrganizationName $OrganizationName."
        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_AuthenticationToken = Set-AzPersonalAccessToken -SecureStringPersonalAccessToken $SecureStringPersonalAccessToken
    }

    #
    # Export the Token information to the Cache Directory

    if ($NoExport.IsPresent) {
        Write-Verbose "[New-AzDoAuthenticationProvider] The Token will not be exported to the Cache Directory."
        return
    }

    # Create an Object Containing the Organization Name.

    $moduleSettingsPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "ModuleSettings.clixml"
    Write-Verbose "[New-AzDoAuthenticationProvider] Exporting the Module Settings to $moduleSettingsPath."

    $objectSettings = [PSCustomObject]@{
        OrganizationName = $AzureDevopsOrganizationName
        Token = $Global:DSCAZDO_AuthenticationToken
    }

    # Export the Object to the Cache Directory
    $objectSettings | Export-Clixml -LiteralPath $moduleSettingsPath

}
