# Save this script as Test-TestAzDevOpsApiHttpRequestHeader.Tests.ps1

# Import the module or script containing the function
. .\Path\To\Your\Script.ps1

Describe "Test-AzDevOpsApiHttpRequestHeader" {

    Context "When using the -IsValid switch" {

        It "should return $true for a valid Managed Identity Token request" {
            $header = @{
                Metadata = "some metadata"
            }
            $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
            $result | Should -Be $true
        }

        It "should return $true for a valid Basic Authorization header" {
            $header = @{
                Authorization = "Basic: dXNlcm5hbWU6cGFzc3dvcmQ="
            }
            $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
            $result | Should -Be $true
        }

        It "should return $true for a valid Bearer Authorization header" {
            $header = @{
                Authorization = "Bearer: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            }
            $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
            $result | Should -Be $true
        }

        It "should return $false for an invalid Authorization header" {
            $header = @{
                Authorization = "InvalidToken"
            }
            $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
            $result | Should -Be $false
        }

        It "should return $false if Authorization header is missing" {
            $header = @{}
            $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
            $result | Should -Be $false
        }

        It "should throw an error if -IsValid switch is not used" {
            $header = @{
                Authorization = "Bearer: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            }
            { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header } | Should -Throw
        }
    }
}
