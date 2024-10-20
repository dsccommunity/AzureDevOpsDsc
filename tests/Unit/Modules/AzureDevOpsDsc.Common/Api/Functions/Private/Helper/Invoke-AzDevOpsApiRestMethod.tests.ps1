$currentFile = $MyInvocation.MyCommand.Path

Describe 'Invoke-AzDevOpsApiRestMethod' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Invoke-AzDevOpsApiRestMethod.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Get 007.APIRateLimit.ps1
        . (Get-ClassFilePath '007.APIRateLimit')

        $defaultParameters = @{
            ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            HttpMethod = 'Get'
            HttpHeaders = @{}
            RetryAttempts = 1
            RetryIntervalMs = 250
        }

        Mock -CommandName Test-AzDevOpsApiHttpRequestHeader -MockWith { return $true }
        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview.1' }
        Mock -CommandName Add-AuthenticationHTTPHeader -MockWith { return $null }

        # Define a custom exception class
        class CustomException : System.Exception {

            [System.Net.WebExceptionStatus]$Status
            [HashTable]$Response

            CustomException([string]$message, [System.Net.WebExceptionStatus]$status,
                            [HashTable]$httpWebResponse, [System.Net.HttpStatusCode]$statusCode) : base($message) {
                $this.Status = $status
                $this.Response = @{
                    StatusCode = $statusCode
                    Headers = $httpWebResponse
                }
            }
        }

    }

    Context 'Basic functionality' {

        BeforeAll {
            Mock -CommandName Invoke-RestMethod -MockWith {
                param (
                    [string]$Uri,
                    [string]$Method,
                    [hashtable]$Headers
                )
                # Default mock behavior can be defined here if needed.
            }
        }

        It 'should call Invoke-RestMethod with correct parameters' {
            Invoke-AzDevOpsApiRestMethod @defaultParameters
            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 1
        }

        It 'should return results from Invoke-RestMethod' {
            Mock -CommandName Invoke-RestMethod -MockWith { return @{ success = $true } }
            $result = Invoke-AzDevOpsApiRestMethod @defaultParameters
            $result | Should -BeOfType [System.Collections.Hashtable]
            $result.success | Should -Be $true
        }
    }

    Context 'Retry mechanism' {
        It 'should retry if Invoke-RestMethod throws' {
            Mock -CommandName Start-Sleep
            Mock -CommandName Invoke-RestMethod -MockWith { throw "Error" }
            $parameters = $defaultParameters.Clone()
            $parameters.RetryAttempts = 2

            { Invoke-AzDevOpsApiRestMethod @parameters } | Should -Throw
            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 3
        }

        It 'should wait between retries' {
            Mock -CommandName Start-Sleep -Verifiable
            Mock -CommandName Invoke-RestMethod -MockWith { throw "Error" }
            $parameters = $defaultParameters.Clone()
            $parameters.RetryAttempts = 2

            { Invoke-AzDevOpsApiRestMethod @parameters } | Should -Throw
            Assert-MockCalled -CommandName Start-Sleep -Exactly -Times 3
        }
    }

    Context 'Continuation token handling' {

        AfterAll {
            Remove-Variable -Name ResponseHeaders -Scope Global -ErrorAction SilentlyContinue
        }

        It 'should handle continuation tokens and loop until no token is found' {

            # First call
            Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -notlike '*continuationToken*' } -MockWith {
                Set-Variable responseHeaders -Value @{ 'x-ms-continuationtoken' = 'token' } -Scope Global
                return @{ success = $true }
            } -Verifiable

            # Second call
            Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like '*continuationToken*' } -MockWith {
                Remove-Variable -Name ResponseHeaders -Scope Global -ErrorAction SilentlyContinue
                return @{ success = $true }
            } -Verifiable

            $parameters = $defaultParameters.Clone()
            $result = Invoke-AzDevOpsApiRestMethod @parameters

            Assert-MockCalled -CommandName Invoke-RestMethod -Times 2
            $result | Should -BeOfType [System.Collections.Hashtable]
            $result.Count | Should -Be 2
        }
    }

    Context 'HTTP 429 Handling' {

        AfterAll {
            Remove-Variable -Name TooManyRequestsFlag -Scope Global -ErrorAction SilentlyContinue
            Remove-Variable -Name DSCAZDO_APIRateLimit -Scope Global -ErrorAction SilentlyContinue
        }

        It 'should handle HTTP 429 and retry with appropriate delay' {

            Mock -CommandName Write-Verbose
            Mock -CommandName Write-Warning

            Mock -CommandName Invoke-RestMethod -MockWith {
                Set-Variable TooManyRequestsFlag -Value $true -Scope Global

                Throw [CustomException]::New(
                    "Too Many Requests",
                    [System.Net.WebExceptionStatus]::ProtocolError,
                    @{ "Retry-After" = 1 },
                    [System.Net.HttpStatusCode]::TooManyRequests
                )

            } -ParameterFilter {
                $null -eq $Global:TooManyRequestsFlag
            }

            Mock -CommandName Invoke-RestMethod -MockWith {
                Remove-Variable -Name TooManyRequestsFlag -Scope Global
                return @{ success = $true }
            } -ParameterFilter {
                $Global:TooManyRequestsFlag -eq $true
            }

            Mock -CommandName Start-Sleep -Verifiable

            $parameters = $defaultParameters.Clone()
            $parameters.RetryAttempts = 2

            $result = Invoke-AzDevOpsApiRestMethod @parameters

            $result | Should -BeOfType [System.Collections.Hashtable]
            Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                $Message -like '*Too Many Requests*'
            }
            Assert-MockCalled -CommandName Write-Verbose -ParameterFilter {
                $Message -like '*seconds before retrying*'
            }
            Assert-MockCalled -CommandName Start-Sleep -Times 1

        }
    }
}
