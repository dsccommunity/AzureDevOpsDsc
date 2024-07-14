powershell
Describe "Invoke-AzDevOpsApiRestMethod Tests" {

    Mock Invoke-RestMethod {
        return @{ SomeProperty = "SomeValue" }
    }

    BeforeAll {
        Import-Module .\path\to\your\module.psm1
    }

    Context "When API call is successful" {
        It "Should return API response" {
            $params = @{
                ApiUri = "https://dev.azure.com/someOrganizationName/_apis/"
                HttpMethod = "Get"
                HttpHeaders = @{}
                HttpBody = ""
                RetryAttempts = 3
                RetryIntervalMs = 250
            }

            $result = Invoke-AzDevOpsApiRestMethod @params
            $result.SomeProperty | Should -Be "SomeValue"
        }
    }

    Context "When retry logic is tested" {
        Mock Invoke-RestMethod {
            if ($Global:retryCount -lt 2) {
                $Global:retryCount++
                throw "API failure"
            } else {
                return @{ SomeProperty = "SomeValue" }
            }
        }

        BeforeAll {
            $Global:retryCount = 0
        }

        It "Should retry specified number of times and return API response" {
            $params = @{
                ApiUri = "https://dev.azure.com/someOrganizationName/_apis/"
                HttpMethod = "Get"
                HttpHeaders = @{}
                HttpBody = ""
                RetryAttempts = 3
                RetryIntervalMs = 250
            }

            $result = Invoke-AzDevOpsApiRestMethod @params
            $result.SomeProperty | Should -Be "SomeValue"
        }
    }

    Context "When max retries are reached" {
        Mock Invoke-RestMethod {
            throw "API failure"
        }

        It "Should throw an error after max retries" {
            $params = @{
                ApiUri = "https://dev.azure.com/someOrganizationName/_apis/"
                HttpMethod = "Get"
                HttpHeaders = @{}
                HttpBody = ""
                RetryAttempts = 3
                RetryIntervalMs = 250
            }

            { Invoke-AzDevOpsApiRestMethod @params } | Should -Throw
        }
    }

    Context "When continuation token is present" {
        Mock Invoke-RestMethod {
            if ($Global:continuationCount -lt 1) {
                $Global:continuationCount++
                return @{ SomeProperty = "SomeValue" }, @{ $responseHeaders = @{ "x-ms-continuationtoken" = "token" } }
            } else {
                return @{ SomeProperty = "SomeValue" }
            }
        }

        BeforeAll {
            $Global:continuationCount = 0
        }

        It "Should handle continuation tokens" {
            $params = @{
                ApiUri = "https://dev.azure.com/someOrganizationName/_apis/"
                HttpMethod = "Get"
                HttpHeaders = @{}
                HttpBody = ""
                RetryAttempts = 3
                RetryIntervalMs = 250
            }

            $result = Invoke-AzDevOpsApiRestMethod @params
            $result.Count | Should -Be 2
        }
    }
}

