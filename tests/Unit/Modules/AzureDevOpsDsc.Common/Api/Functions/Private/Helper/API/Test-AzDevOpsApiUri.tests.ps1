# Save this script as Test-TestAzDevOpsApiUri.Tests.ps1

# Import the module or script containing the function
. .\Path\To\Your\Script.ps1

Describe "Test-AzDevOpsApiUri" {

    Context "When validating URI format with -IsValid switch" {

        It "should return $true for a valid Azure DevOps API URI (http)" {
            $apiUri = 'http://dev.azure.com/organization/project/_apis/'
            $result = Test-AzDevOpsApiUri -ApiUri $apiUri -IsValid
            $result | Should -Be $true
        }

        It "should return $true for a valid Azure DevOps API URI (https)" {
            $apiUri = 'https://dev.azure.com/organization/project/_apis/'
            $result = Test-AzDevOpsApiUri -ApiUri $apiUri -IsValid
            $result | Should -Be $true
        }

        It "should return $false for an invalid Azure DevOps API URI without protocol" {
            $apiUri = 'dev.azure.com/organization/project/_apis/'
            $result = Test-AzDevOpsApiUri -ApiUri $apiUri -IsValid
            $result | Should -Be $false
        }

        It "should return $false for an invalid Azure DevOps API URI without _apis segment" {
            $apiUri = 'https://dev.azure.com/organization/project/'
            $result = Test-AzDevOpsApiUri -ApiUri $apiUri -IsValid
            $result | Should -Be $false
        }

        It "should return $true if ApiUri is not provided" {
            $result = Test-AzDevOpsApiUri -IsValid
            $result | Should -Be $true
        }

        It "should throw an error if -IsValid switch is not used" {
            $apiUri = 'https://dev.azure.com/organization/project/_apis/'
            { Test-AzDevOpsApiUri -ApiUri $apiUri } | Should -Throw
        }
    }
}
