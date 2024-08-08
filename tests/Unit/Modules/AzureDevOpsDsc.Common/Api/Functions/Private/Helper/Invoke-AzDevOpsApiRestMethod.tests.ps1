Describe 'Invoke-AzDevOpsApiRestMethod' {
    Mock -CommandName Invoke-RestMethod

    $defaultParameters = @{
        ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
        HttpMethod = 'Get'
        HttpHeaders = @{}
        RetryAttempts = 1
        RetryIntervalMs = 250
    }

    Context 'Basic functionality' {
        It 'should call Invoke-RestMethod with correct parameters' {
            Invoke-AzDevOpsApiRestMethod @defaultParameters
            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 1
        }

        It 'should return results from Invoke-RestMethod' {
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ success = $true } }
            $result = Invoke-AzDevOpsApiRestMethod @defaultParameters
            $result | Should -BeOfType [System.Collections.ArrayList]
            $result[0].success | Should -Be $true
        }
    }

    Context 'Retry mechanism' {
        It 'should retry if Invoke-RestMethod throws' {
            Mock -CommandName Invoke-RestMethod -MockWith { throw "Error" }
            $parameters = @defaultParameters
            $parameters.RetryAttempts = 2

            { Invoke-AzDevOpsApiRestMethod @parameters } | Should -Throw
            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 3
        }

        It 'should wait between retries' {
            Mock -CommandName Start-Sleep
            Mock -CommandName Invoke-RestMethod -MockWith { throw "Error" }
            $parameters = @defaultParameters
            $parameters.RetryAttempts = 2

            { Invoke-AzDevOpsApiRestMethod @parameters } | Should -Throw
            Assert-MockCalled -CommandName Start-Sleep -Exactly -Times 2
        }
    }

    Context 'Continuation token handling' {
        It 'should handle continuation tokens and loop until no token is found' {
            $responseHeaders = @{
                'x-ms-continuationtoken' = 'token'
            }
            Mock -CommandName Invoke-RestMethod -MockWith {
                param ($ResponseHeadersVariable)
                Set-Variable -Name $ResponseHeadersVariable -Value $responseHeaders -Scope Global
                return @{ success = $true }
            } -Verifiable
            Mock -CommandName Invoke-RestMethod -MockWith { return @{} }
            $parameters = @defaultParameters

            $result = Invoke-AzDevOpsApiRestMethod @parameters

            Assert-MockCalled -CommandName Invoke-RestMethod -AtLeast -Times 2
            $result | Should -BeOfType [System.Collections.ArrayList]
        }
    }

    Context 'HTTP 429 Handling' {
        It 'should handle HTTP 429 and retry with appropriate delay' {
            Mock -CommandName Invoke-RestMethod -MockWith {
                throw [System.Net.WebException]::new("Too Many Requests", [System.Net.WebExceptionStatus]::ProtocolError, ([System.Net.HttpWebResponse]@{
                    StatusCode = [System.Net.HttpStatusCode]::TooManyRequests
                    Headers = [Ordered]@{ "Retry-After" = 1 }
                }))
            }
            Mock -CommandName Start-Sleep -MockWith { param($Milliseconds); return $null }
            $parameters = @defaultParameters
            $parameters.RetryAttempts = 2

            { Invoke-AzDevOpsApiRestMethod @parameters } | Should -Throw
            Assert-MockCalled -CommandName Start-Sleep -Exactly -Times 2
        }
    }
}

