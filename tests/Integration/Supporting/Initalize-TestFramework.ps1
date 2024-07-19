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

# Confirm the Authentication Type
if ($TestFrameworkConfiguration.AuthenticationType -eq 'PAT')
{

} elseif ($TestFrameworkConfiguration.AuthenticationType -eq 'ManagedIdentity')
{

} else {
    throw "[Initialize-TestFramework] Invalid Authentication Type: $($TestFrameworkConfiguration.AuthenticationType)"
}



#
# Depending on the Type, validate the configuration

if ($Type -eq 'BeforeAll')
{



}
