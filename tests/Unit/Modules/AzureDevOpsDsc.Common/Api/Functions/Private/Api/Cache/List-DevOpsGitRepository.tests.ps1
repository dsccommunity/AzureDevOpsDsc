powershell
Describe "List-DevOpsGitRepository" {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "6.0" }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    $orgName = "TestOrganization"
    $projName = "TestProject"
    $apiVersionDefault = "6.0"
    $apiResponse = [PSCustomObject]@{
        Value = @(
            [PSCustomObject]@{ name = "Repo1" },
            [PSCustomObject]@{ name = "Repo2" }
        )
    }

    Context "When API returns repositories" {
        Mock Invoke-AzDevOpsApiRestMethod {
            param (
                [Parameter(Mandatory = $true)][string]$Uri,
                [Parameter(Mandatory = $true)][string]$Method
            )
            return $apiResponse
        }

        It "should return the repository list" {
            $result = List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName
            $result | Should -BeExactly $apiResponse.Value
        }
    }

    Context "When API returns null value" {
        Mock Invoke-AzDevOpsApiRestMethod {
            param (
                [Parameter(Mandatory = $true)][string]$Uri,
                [Parameter(Mandatory = $true)][string]$Method
            )
            return [PSCustomObject]@{ value = $null }
        }

        It "should return null" {
            $result = List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName
            $result | Should -BeNull
        }
    }

    Context "With Default API Version" {
        It "should use default API version from Get-AzDevOpsApiVersion" {
            List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }
    }

    Context "Including API Version Parameter" {
        It "should use provided API version" {
            $apiVersion = "5.1"
            List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName -ApiVersion $apiVersion
            Assert-MockCalled Get-AzDevOpsApiVersion -Times 0
        }
    }
}

