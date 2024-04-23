
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

    Describe 'Invoke-AzDevOpsApiRestMethod' {
        Mock Invoke-RestMethod { return @{ Value = "Success" } }
        Mock Start-Sleep {}
        Mock Test-AzDevOpsApiHttpRequestHeader { return $true }
        Mock Get-AzDevOpsApiVersion { return "1.0" }
        Mock Update-AzManagedIdentityToken { return @{ Get = { "token" }; isExpired = { $false } } }
        Mock New-InvalidOperationException {}

        It 'Successfully invokes a GET method without retries' {
            $result = Invoke-AzDevOpsApiRestMethod -ApiUri 'https://dev.azure.com/organization/_apis/' -HttpMethod 'Get'
            $result.Value | Should -BeExactly "Success"
        }

        It 'Retries the specified number of times on failure and then throws' {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new() } -Verifiable
            { Invoke-AzDevOpsApiRestMethod -ApiUri 'https://dev.azure.com/organization/_apis/' -HttpMethod 'Get' -RetryAttempts 2 } | Should -Throw
            Assert-MockCalled Invoke-RestMethod -Exactly 3 -Scope It # Initial + 2 retries
        }

        It 'Handles rate limiting by waiting before retrying' {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new() } -Verifiable
            $Global:DSCAZDO_APIRateLimit = @{ xRateLimitRemaining = 0; retryAfter = 1 }
            { Invoke-AzDevOpsApiRestMethod -ApiUri 'https://dev.azure.com/organization/_apis/' -HttpMethod 'Get' -RetryAttempts 1 } | Should -Throw
            Assert-MockCalled Start-Sleep -Exactly 1 -Scope It
            $Global:DSCAZDO_APIRateLimit = $null
        }

        It 'Handles continuation tokens properly' {
            Mock Invoke-RestMethod { return @{ 'x-ms-continuationtoken' = 'abc123' } } -Verifiable
            Invoke-AzDevOpsApiRestMethod -ApiUri 'https://dev.azure.com/organization/_apis/' -HttpMethod 'Get' -RetryAttempts 0
            Assert-MockCalled Invoke-RestMethod -Exactly 2 -Scope It # Initial + continuation token call
        }

        It 'Throws an error after all retries have been exhausted' {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new() } -Verifiable
            { Invoke-AzDevOpsApiRestMethod -ApiUri 'https://dev.azure.com/organization/_apis/' -HttpMethod 'Get' -RetryAttempts 1 } | Should -Throw
            Assert-MockCalled New-InvalidOperationException -Exactly 1 -Scope It
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
