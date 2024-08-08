param(
    [Parameter(Mandatory)]
    [String]$TestFrameworkConfigurationPath,
    [Parameter(Mandatory)]
    [ValidateSet('BeforeAll', 'BeforeEach', 'AfterEach', 'AfterAll')]
    [String]$Type
)

#
# Test Framework Configuration
if (-not (Test-Path $TestFrameworkConfigurationPath))
{
    throw "[Initialize-TestFramework] Test Framework Configuration file not found at $TestFrameworkConfigurationPath"
}

#
# Attempt to load the configuration
$TestFrameworkConfiguration = Get-Content $TestFrameworkConfigurationPath | ConvertFrom-Json

# Confirm the Organization
if (-not $TestFrameworkConfiguration.Organization)
{
    throw "[Initialize-TestFramework] Organization not specified in the Test Framework Configuration"
}

# Confirm the Authentication Type
if ($TestFrameworkConfiguration.AuthenticationType -eq 'PAT')
{
    # Authenticate with a Personal Access Token
    New-AzDoAuthenticationProvider -OrganizationName $AzureDevopsOrganizationName -PersonalAccessToken $TestFrameworkConfiguration.PATToken
} elseif ($TestFrameworkConfiguration.AuthenticationType -eq 'ManagedIdentity') {
    # Authenticate with a Managed Identity
    New-AzDoAuthenticationProvider -OrganizationName $AzureDevopsOrganizationName -useManagedIdentity
} else {
    throw "[Initialize-TestFramework] Invalid Authentication Type: $($TestFrameworkConfiguration.AuthenticationType)"
}


