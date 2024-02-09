
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

<#
.DESCRIPTION
    A set of Pester tests to verify the behavior of the Invoke-AzDevOpsApiRestMethod function.
#>

# Importing the module which contains the function (assuming it's in a module)
# Import-Module 'PathToYourPowerShellModule'

InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

   . $script:commandScriptPath

    Describe "Invoke-AzDevOpsApiRestMethod Tests" {

        AfterEach {
            $Global:responseHeaders = $null
            $Global:calledOnce = $null
        }

        BeforeAll {
            # Mocking the Invoke-RestMethod to prevent actual API calls during testing
            Mock Invoke-RestMethod { return @{ Value = "Mocked result"; Headers = @{ 'x-ms-continuationtoken' = $null }} }

            # Mocking Start-Sleep to prevent actual delays during testing
            Mock Start-Sleep {}

            # Initializing variables that are used globally within the function
            $Global:DSCAZDO_APIRateLimit = @{}
        }

        It "Should call Invoke-RestMethod with correct parameters" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }

            # Act
            Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders

            # Assert
            Assert-MockCalled Invoke-RestMethod -Times 1 -Exactly -Scope It
        }

        It "Should not include Body and ContentType for Get and Delete methods" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }

            # Act
            Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders

            # Assert
            Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                $PSBoundParameters.ContainsKey('Body') -eq $false -and
                $PSBoundParameters.ContainsKey('ContentType') -eq $false
            } -Times 1 -Exactly -Scope It
        }

        It "Should retry the specified number of attempts on failure" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }
            $RetryAttempts = 2

            # Mocking Invoke-RestMethod to throw an exception to simulate a failure
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new() } -Verifiable

            # Act & Assert
            { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders -RetryAttempts $RetryAttempts } | Should -Throw

            # Assert that Invoke-RestMethod was called the expected number of times
            Assert-MockCalled Invoke-RestMethod -Times ($RetryAttempts + 1) -Exactly -Scope It
        }

        It "Should handle continuation tokens correctly" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }

            # Mock Invoke-RestMethod to return a continuation token on the first call
            Mock Invoke-RestMethod {
                if (!$calledOnce) {
                    $Global:calledOnce = $true
                    $Global:responseHeaders = @{ 'x-ms-continuationtoken' = 'abc123' }
                    return @{ Value = "Partial result" }
                } else {
                    $Global:responseHeaders = $null
                    return @{ Value = "Final result" }
                }
            } -Verifiable

            # Act
            $result = Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders

            # Assert
            $result.Count | Should -Be 2
            $result[0].Value | Should -Be "Partial result"
            $result[1].Value | Should -Be "Final result"
            Assert-MockCalled Invoke-RestMethod -Times 2 -Exactly -Scope It
        }

    }

    Describe "Invoke-AzDevOpsApiRestMethod Rate Limiting Tests" {

        BeforeEach {
            # Initializing variables that are used globally within the function
            $Global:DSCAZDO_APIRateLimit = @{}
            $Global:responseHeaders = @{}

            $script:localizedData = @{ AzDevOpsApiRestMethodException = "{0} - {1} - {2}" }

        }

        AfterEach {
            # Clearing the global variables
            $Global:DSCAZDO_APIRateLimit = $null
            $Global:responseHeaders = $null
        }

        It "Should handle HTTP 429 status code and respect Retry-After header" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }
            $RetryAfterSeconds = 3

            Mock Invoke-RestMethod {

                $response = [System.Net.Http.HttpResponseMessage]::New([System.Net.HttpStatusCode]::TooManyRequests)
                $exception = [Microsoft.PowerShell.Commands.HttpResponseException]::New("Too many requests", $response)
                $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                $errorID = 'WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeRestMethodCommand'
                $targetObject = $null
                $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, $errorID, $errorCategory, $targetObject)
                $errorRecord.errorDetails = 'Too many requests'
                $response.Headers.Add('Retry-After', $RetryAfterSeconds)

                throw $errorRecord
            }

            Mock Start-Sleep {}

            # Act & Assert
            { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders } | Should -Throw

            # Assert that Start-Sleep was called with the correct number of seconds from Retry-After header
            Assert-MockCalled Start-Sleep -ParameterFilter { $Seconds -eq $RetryAfterSeconds } -Times 1 -Scope It
        }

        It "Should wait for RetryIntervalMs if xRateLimitRemaining is close to being overwhelmed" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }
            $RetryIntervalMs = 250

            # Setting a mock value to simulate the xRateLimitRemaining being low but not exhausted
            $Global:DSCAZDO_APIRateLimit.xRateLimitRemaining = 10

            Mock Invoke-RestMethod {}
            Mock Start-Sleep {}

            # Act
            Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders

            # Assert that Start-Sleep was called with the correct milliseconds when xRateLimitRemaining is low
            Assert-MockCalled Start-Sleep -ParameterFilter { $Milliseconds -eq $RetryIntervalMs } -Times 1 -Exactly -Scope It
        }

        It "Should wait for RetryIntervalMs if xRateLimitRemaining is overwhelmed" {
            # Arrange
            $ApiUri = 'https://dev.azure.com/someOrganizationName/_apis/'
            $HttpMethod = 'Get'
            $HttpHeaders = @{ Authorization = "Bearer fakeToken" }
            $RetryIntervalMs = 250

            # Setting a mock value to simulate the xRateLimitRemaining being exhausted
            $Global:DSCAZDO_APIRateLimit.xRateLimitRemaining = 4

            Mock Invoke-RestMethod {}
            Mock Start-Sleep {}

            # Act
            Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpHeaders $HttpHeaders

            # Assert that Start-Sleep was called with the correct milliseconds when xRateLimitRemaining is exhausted
            Assert-MockCalled Start-Sleep -ParameterFilter { $Milliseconds -eq $RetryIntervalMs } -Times 1 -Exactly -Scope It
        }
    }

}
