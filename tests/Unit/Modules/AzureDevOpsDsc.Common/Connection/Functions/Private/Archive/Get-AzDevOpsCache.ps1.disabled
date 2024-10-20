<#
.SYNOPSIS
    Retrieves the Azure DevOps API cache.

.DESCRIPTION
    The Get-AzDevOpsApiCache function is used to retrieve the cached data from the Azure DevOps API. It checks for the presence of the cache files and verifies the parameters before returning the cached data.

.PARAMETER ApiEndpoint
    Specifies the API endpoint to retrieve the cache for.

.PARAMETER Parameters
    Specifies the parameters used for the API endpoint.

.EXAMPLE
    Get-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' }

    This example retrieves the cached data for the 'projects/list' API endpoint with the specified parameters.

#>

. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {
    Describe 'Get-AzDevOpsApiCache Tests' {
        BeforeAll {
            # Mock the environment variable for cache path
            $env:AZDODSCCachePath = "TestCachePath"

            # Define test data
            $testApiEndpoint = 'projects/list'
            $testParameters = @{ organization = 'myOrg' }
            $normalizedApiEndpoint = $testApiEndpoint -replace '[\/:\*\?"<>|]', '_'
            $metadataFilePath = Join-Path -Path $env:AZDODSCCachePath -ChildPath "${normalizedApiEndpoint}_test.metadata.json"
            $cacheFilePath = Join-Path -Path $env:AZDODSCCachePath -ChildPath "${normalizedApiEndpoint}_test.cache.json"

            # Create mock metadata and cache files
            $metadataObject = @{
                Parameters = @{ organization = 'myOrg' }
                CacheFile = "${normalizedApiEndpoint}_test.cache.json"
            } | ConvertTo-Json
            Set-Content -Path $metadataFilePath -Value $metadataObject

            $cacheObject = @{
                Data = "Cached API response"
            } | ConvertTo-Json
            Set-Content -Path $cacheFilePath -Value $cacheObject
        }

        It 'Throws an exception if AZDODSCCachePath environment variable is not set' {
            # Temporarily remove the environment variable
            Remove-Item Env:\AZDODSCCachePath

            { Get-AzDevOpsApiCache -ApiEndpoint $testApiEndpoint -Parameters $testParameters } | Should -Throw -ExpectedMessage 'AZDODSCCachePath environment variable is not set.'

            # Restore the environment variable
            $env:AZDODSCCachePath = "TestCachePath"
        }

        It 'Returns $null if no metadata files are found' {
            Mock Get-ChildItem { return @() }

            $result = Get-AzDevOpsApiCache -ApiEndpoint $testApiEndpoint -Parameters $testParameters
            $result | Should -Be $null
        }

        It 'Returns $null if parameters do not match' {
            $wrongParameters = @{ organization = 'anotherOrg' }

            $result = Get-AzDevOpsApiCache -ApiEndpoint $testApiEndpoint -Parameters $wrongParameters
            $result | Should -Be $null
        }

        It 'Returns cache content if parameters match and cache file exists' {
            $result = Get-AzDevOpsApiCache -ApiEndpoint $testApiEndpoint -Parameters $testParameters
            $result.Data | Should -Be 'Cached API response'
        }

        AfterAll {
            # Clean up test files
            Remove-Item $metadataFilePath
            Remove-Item $cacheFilePath

            # Clean up environment variable
            Remove-Item Env:\AZDODSCCachePath
        }
    }
}
