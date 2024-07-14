# Save this script as Test-TestAzDevOpsApiResourceId.Tests.ps1

# Import the module or script containing the function
. .\Path\To\Your\Script.ps1

Describe "Test-AzDevOpsApiResourceId" {

    Context "When using the -IsValid switch" {

        It "should return $true for a valid GUID ResourceId" {
            $resourceId = "123e4567-e89b-12d3-a456-426614174000"
            $result = Test-AzDevOpsApiResourceId -ResourceId $resourceId -IsValid
            $result | Should -Be $true
        }

        It "should return $false for an invalid GUID ResourceId" {
            $resourceId = "invalid-guid"
            $result = Test-AzDevOpsApiResourceId -ResourceId $resourceId -IsValid
            $result | Should -Be $false
        }

        It "should return $false for an empty string ResourceId" {
            $resourceId = ""
            $result = Test-AzDevOpsApiResourceId -ResourceId $resourceId -IsValid
            $result | Should -Be $false
        }

        It "should throw an error if -IsValid switch is not used" {
            $resourceId = "123e4567-e89b-12d3-a456-426614174000"
            { Test-AzDevOpsApiResourceId -ResourceId $resourceId } | Should -Throw
        }
    }
}
