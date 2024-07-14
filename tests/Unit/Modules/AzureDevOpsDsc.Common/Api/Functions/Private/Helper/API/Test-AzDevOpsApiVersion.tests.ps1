# Save this script as Test-TestAzDevOpsApiVersion.Tests.ps1

# Import the module or script containing the function
. .\Path\To\Your\Script.ps1

Describe "Test-AzDevOpsApiVersion" {

    Context "When validating API version with -IsValid switch" {

        It "should return $true for a supported API version" {
            $apiVersion = '6.0'
            $result = Test-AzDevOpsApiVersion -ApiVersion $apiVersion -IsValid
            $result | Should -Be $true
        }

        It "should return $false for an unsupported API version" {
            $apiVersion = '5.0'
            $result = Test-AzDevOpsApiVersion -ApiVersion $apiVersion -IsValid
            $result | Should -Be $false
        }

        It "should throw an error if -IsValid switch is not used" {
            $apiVersion = '6.0'
            { Test-AzDevOpsApiVersion -ApiVersion $apiVersion } | Should -Throw
        }

        It "should throw an error if ApiVersion parameter is missing" {
            { Test-AzDevOpsApiVersion -IsValid } | Should -Throw
        }
    }
}
