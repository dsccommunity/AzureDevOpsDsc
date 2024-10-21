# A Stripped Down version of New-AzDoAuthenticationProvider
Function New-AuthProvider {

    [CmdletBinding(DefaultParameterSetName = 'PersonalAccessToken')]
    param (
        # Organization Name
        [Parameter(Mandatory = $true, ParameterSetName = 'PersonalAccessToken')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ManagedIdentity')]
        [Alias('OrgName')]
        [String]
        $OrganizationName,

        # Personal Access Token
        [Parameter(Mandatory = $true, ParameterSetName = 'PersonalAccessToken')]
        [Alias('PAT')]
        [String]
        $PersonalAccessToken,

        # Use Managed Identity
        [Parameter(ParameterSetName = 'ManagedIdentity')]
        [Switch]
        $useManagedIdentity
    )

    # Set the Global Variables
    $Global:DSCAZDO_OrganizationName = $OrganizationName
    $Global:DSCAZDO_AuthenticationToken = $null

    # If the parameterset is PersonalAccessToken
    if ($PSCmdlet.ParameterSetName -eq 'PersonalAccessToken')
    {
        Write-Verbose "[New-AuthProvider] Creating a new Personal Access Token with OrganizationName $OrganizationName."
        $Global:DSCAZDO_AuthenticationToken = @{
            'token' = ':{0}' -f (ConvertTo-Base64String $PersonalAccessToken)
            'type' = 'PAT'
        }
    }
    # If the parameterset is ManagedIdentity
    elseif ($PSCmdlet.ParameterSetName -eq 'ManagedIdentity')
    {
        Write-Verbose "[New-AuthProvider] Creating a new Azure Managed Identity with OrganizationName $OrganizationName."
        # If the Token is not Valid. Get a new Token.
        $Global:DSCAZDO_AuthenticationToken = @{
            'token' = Get-MIToken -OrganizationName $OrganizationName
            'type' = 'ManagedIdentity'
        }
    }

}
