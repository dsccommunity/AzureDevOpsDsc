<#
.SYNOPSIS
Unit tests for the New-AzDevOpsApiCache function.

.DESCRIPTION
This script contains unit tests for the New-AzDevOpsApiCache function in the AzureDevOpsDsc.Common module. The tests cover various scenarios such as error handling, cache directory creation, file generation, and parameter handling.

.PARAMETER ApiEndpoint
The API endpoint to be cached.

.PARAMETER Parameters
The parameters to be passed to the API endpoint.

.PARAMETER Content
The content to be cached.

.PARAMETER Depth
The depth of the JSON conversion.

.EXAMPLE
#>

. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1

Describe 'New-AzDevOpsApiCache Tests' {
    BeforeAll {
        # Mock the Get-Date cmdlet to return a predictable date-time
        Mock Get-Date { return [DateTime]::ParseExact('2023-01-01T00:00:00.0000000Z', 'o', $null) }
    }

    It 'Throws an error when AZDODSCCachePath is not set' {
        # Temporarily clear the AZDODSCCachePath environment variable for this test
        $originalAzDodscCachePath = $ENV:AZDODSCCachePath
        $ENV:AZDODSCCachePath = $null

        { New-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' } -Content @{ key1 = 'value1' } } | Should -Throw 'AZDODSCCachePath environment variable is not set.'

        # Restore the original AZDODSCCachePath value
        $ENV:AZDODSCCachePath = $originalAzDodscCachePath
    }

    It 'Creates the cache directory if it does not exist' {
        Mock Test-Path { return $false }
        Mock New-Item {}

        New-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' } -Content @{ key1 = 'value1' }

        Assert-MockCalled New-Item -Times 1 -Exactly
    }

    It 'Generates cache and metadata files with correct content' {
        Mock Out-File {}

        $content = @{ key1 = 'value1'; key2 = 'value2' }
        New-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' } -Content $content

        Assert-MockCalled Out-File -Times 2 -Exactly
    }

    It 'Handles the Depth parameter correctly' {
        Mock ConvertTo-Json { return '{}' }

        $content = @{ key1 = @{ subKey = 'subValue' } }
        New-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' } -Content $content -Depth 5

        Assert-MockCalled ConvertTo-Json -ParameterFilter { $Depth -eq 5 } -Times 1 -Exactly
    }
}
