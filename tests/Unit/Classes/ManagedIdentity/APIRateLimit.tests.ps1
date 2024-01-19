# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    Describe "APIRateLimit Class Tests" {
        Context "Constructor with Hashtable" {
            It "Initializes correctly with a valid hashtable" {
                $validHashTable = @{
                    'Retry-After'           = 120
                    'X-RateLimit-Remaining' = 10
                    'X-RateLimit-Reset'     = 1588342322
                }

                { [APIRateLimit]::new($validHashTable) } | Should -Not -Throw
                $apiRateLimit = [APIRateLimit]::new($validHashTable)
                $apiRateLimit.retryAfter | Should -Be 120
                $apiRateLimit.XRateLimitRemaining | Should -Be 10
                $apiRateLimit.XRateLimitReset | Should -Be 1588342322
            }

            It "Throws an error with an invalid hashtable" {
                $invalidHashTable = @{
                    'Retry-After' = 120
                    # Missing 'X-RateLimit-Remaining' and 'X-RateLimit-Reset'
                }

                { [APIRateLimit]::new($invalidHashTable) } | Should -Throw "The APIRateLimitObj is not valid."
            }
        }

        Context "Constructor with Retry-After Parameter" {
            It "Initializes correctly with a retryAfter parameter" {
                { [APIRateLimit]::new(150) } | Should -Not -Throw
                $apiRateLimit = [APIRateLimit]::new(150)
                $apiRateLimit.retryAfter | Should -Be 150
            }
        }

        Context "isValid Method" {
            It "Returns true for a valid hashtable" {
                $validHashTable = @{
                    'Retry-After'         = 120
                    'X-RateLimit-Remaining' = 10
                    'X-RateLimit-Reset'   = 1588342322
                }
                $apiRateLimit = [APIRateLimit]::new($validHashTable)
                $result = $apiRateLimit.isValid($validHashTable)
                $result | Should -Be $true
            }

            It "Returns false for an invalid hashtable" {
                $invalidHashTable = @{
                    'Retry-After' = 120
                    # Missing 'X-RateLimit-Remaining' and 'X-RateLimit-Reset'
                }
                $apiRateLimit = [APIRateLimit]::new(150)
                $result = $apiRateLimit.isValid($invalidHashTable)
                $result | Should -Be $false
            }
        }
    }

}
