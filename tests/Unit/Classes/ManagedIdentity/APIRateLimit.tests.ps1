<#
.SYNOPSIS
    Test suite for the APIRateLimit class.

.DESCRIPTION
    This test suite validates the functionality of the APIRateLimit class, ensuring it properly handles valid and invalid inputs.
#>

# Initialize tests for module function
. $PSScriptRoot\..\Classes.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc' {

    Describe "APIRateLimit Class Tests" {

        It "Throws an exception when initialized with an invalid HashTable (missing keys)" {
            # Arrange
            $invalidHashTable = @{ 'Retry-After' = 120 }
            # Act / Assert
            { [APIRateLimit]::new($invalidHashTable) } | Should -Throw "The APIRateLimitObj is not valid."
        }

        It "Does not throw an exception when initialized with a valid HashTable" {
            # Arrange
            $validHashTable = @{
                'Retry-After'           = 120
                'X-RateLimit-Remaining' = 10
                'X-RateLimit-Reset'     = 1583000000
            }
            # Act / Assert
            { [APIRateLimit]::new($validHashTable) } | Should -Not -Throw
        }

        It "Correctly sets the properties when initialized with a valid HashTable" {
            # Arrange
            $validHashTable = @{
                'Retry-After'           = 120
                'X-RateLimit-Remaining' = 10
                'X-RateLimit-Reset'     = 1583000000
            }
            $expectedEpochTime = [datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc).AddSeconds(1583000000)
            # Act
            $apiRateLimit = [APIRateLimit]::new($validHashTable)
            # Assert
            $apiRateLimit.retryAfter | Should -Be 120
            $apiRateLimit.XRateLimitRemaining | Should -Be 10
            $apiRateLimit.XRateLimitReset | Should -Be 1583000000
        }

        It "Initializes with only retryAfter parameter correctly" {
            # Arrange
            $retryAfterValue = 300
            # Act
            $apiRateLimit = [APIRateLimit]::new($retryAfterValue)
            # Assert
            $apiRateLimit.retryAfter | Should -Be $retryAfterValue
            $apiRateLimit.XRateLimitRemaining | Should -Be 0
            $apiRateLimit.XRateLimitReset | Should -Be 0
        }

        It "isValid method returns false when HashTable is missing keys" {
            # Arrange
            $incompleteHashTable = @{ 'Retry-After' = 120 }
            $apiRateLimit = [APIRateLimit]::new(0)
            # Act
            $result = $apiRateLimit.isValid($incompleteHashTable)
            # Assert
            $result | Should -Be $false
        }

        It "isValid method returns true when HashTable has all required keys" {
            # Arrange
            $completeHashTable = @{
                'Retry-After'           = 120
                'X-RateLimit-Remaining' = 10
                'X-RateLimit-Reset'     = 1583000000
            }
            $apiRateLimit = [APIRateLimit]::new(0)
            # Act
            $result = $apiRateLimit.isValid($completeHashTable)
            # Assert
            $result | Should -Be $true
        }
    }

}
# Note: To execute this test suite, save it to a file named 'APIRateLimit.Tests.ps1' and run it using Pester.
