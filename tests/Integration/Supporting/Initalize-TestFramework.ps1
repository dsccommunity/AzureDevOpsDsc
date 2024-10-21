param(
    [Parameter(Mandatory = $true)]
    [String]$TestFrameworkConfigurationPath
)

Import-Module DscResource.Common.psd1
Import-Module AzureDevOpsDsc.Common.psd1
Import-Module AzureDevOpsDsc.psd1

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
    #New-AuthProvider -OrganizationName $TestFrameworkConfiguration.Organization -PersonalAccessToken $TestFrameworkConfiguration.PATToken
    New-AzDoAuthenticationProvider -OrganizationName $TestFrameworkConfiguration.Organization -PersonalAccessToken $TestFrameworkConfiguration.PATToken
}
elseif ($TestFrameworkConfiguration.AuthenticationType -eq 'ManagedIdentity')
{
    # Authenticate with a Managed Identity
    #New-AuthProvider -OrganizationName $TestFrameworkConfiguration.Organization -useManagedIdentity
    New-AzDoAuthenticationProvider -OrganizationName $TestFrameworkConfiguration.Organization -useManagedIdentity
}
else
{
    throw "[Initialize-TestFramework] Invalid Authentication Type: $($TestFrameworkConfiguration.AuthenticationType)"
}


