# Requires -Module Pester -Version 5.0.0
# Requires -Module DscResource.Common

# Test if the class is defined
if ($null -eq $Global:ClassesLoaded)
{
    # Attempt to find the root of the repository
    $RepositoryRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
    # Load the Dependencies
    . "$RepositoryRoot\azuredevopsdsc.tests.ps1" -LoadModulesOnly
}

Describe 'APIRateLimit' {

    BeforeAll {
        Mock Write-Warning
    }

    Context 'Constructor with HashTable parameter' {
        It 'should initialize properties correctly when given a valid hashtable' {
            $validHashTable = @{
                'Retry-After' = 10
                'X-RateLimit-Remaining' = 100
                'X-RateLimit-Reset' = 1609459200 # Unix time for 2021-01-01 00:00:00 UTC
            }

            $apiRateLimit = [APIRateLimit]::new($validHashTable)

            $apiRateLimit.retryAfter | Should -Be 10
            $apiRateLimit.XRateLimitRemaining | Should -Be 100
            $apiRateLimit.XRateLimitReset | Should -Be 1609459200
        }

        It 'should throw an error when given an invalid hashtable' {
            $invalidHashTable = @{
                'Retry-After' = 10
                'X-RateLimit-Remaining' = 100
                # Missing 'X-RateLimit-Reset'
            }

            { [APIRateLimit]::new($invalidHashTable) } | Should -Throw "The APIRateLimitObj is not valid."
        }
    }

    Context 'Constructor with retryAfter parameter' {
        It 'should initialize retryAfter property correctly' {
            $retryAfterValue = 5
            $apiRateLimit = [APIRateLimit]::new($retryAfterValue)

            $apiRateLimit.retryAfter | Should -Be $retryAfterValue
        }
    }

    Context 'isValid method' {
        It 'should return true for a valid hashtable' {
            $validHashTable = @{
                'Retry-After' = 10
                'X-RateLimit-Remaining' = 100
                'X-RateLimit-Reset' = 1609459200
            }
            $apiRateLimit = [APIRateLimit]::new($validHashTable)
            $result = $apiRateLimit.isValid($validHashTable)

            $result | Should -Be $true
        }

        It 'should return false for an invalid hashtable' {
            $invalidHashTable = @{
                'Retry-After' = 10
                'X-RateLimit-Remaining' = 100
                # Missing 'X-RateLimit-Reset'
            }
            {[APIRateLimit]::new($invalidHashTable)} | Should -Throw '*The APIRateLimitObj is not valid*'
        }
    }
}
