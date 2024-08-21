$currentFile = $MyInvocation.MyCommand.Path

Describe "Wait-DevOpsProject" {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ status = 'wellFormed' }
        }

        Mock -CommandName Write-Error

    }

    Context "When project is created successfully" {

        It "Should detect the project has been created successfully and exit the loop" {
            $organizationName = "TestOrg"
            $projectURL = "https://dev.azure.com/TestOrg/TestProject"
            $apiVersion = "6.0"

            $params = @{
                OrganizationName = $organizationName
                ProjectURL       = $projectURL
                ApiVersion       = $apiVersion
            }

            { Wait-DevOpsProject @params } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Time 1
        }
    }

    Context "When project creation fails" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ status = 'failed'; message = 'Creation failed' }
        }

        It "Should detect the failure and write an error message" {
            $organizationName = "TestOrg"
            $projectURL = "https://dev.azure.com/TestOrg/TestProject"
            $apiVersion = "6.0"

            $params = @{
                OrganizationName = $organizationName
                ProjectURL       = $projectURL
                ApiVersion       = $apiVersion
            }

            { Wait-DevOpsProject @params } | Should -Not -Throw

            Assert-MockCalled -CommandName Write-Error
        }
    }

    Context "When project creation times out" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ status = 'creating' }
        }

        It "Should time out after 10 attempts and write an error message" {
            $organizationName = "TestOrg"
            $projectURL = "https://dev.azure.com/TestOrg/TestProject"
            $apiVersion = "6.0"

            $params = @{
                OrganizationName = $organizationName
                ProjectURL       = $projectURL
                ApiVersion       = $apiVersion
            }

            { Wait-DevOpsProject @params } | Should -Not -Throw

            Assert-MockCalled -CommandName Write-Error
        }
    }

    Context "When project creation status is not set" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ status = 'notSet'; message = 'Status not set' }
        }

        It "Should detect the status is not set and write an error message" {

            $organizationName = "TestOrg"
            $projectURL = "https://dev.azure.com/TestOrg/TestProject"
            $apiVersion = "6.0"

            $params = @{
                OrganizationName = $organizationName
                ProjectURL       = $projectURL
                ApiVersion       = $apiVersion
            }

            { Wait-DevOpsProject @params } | Should -Not -Throw

            Assert-MockCalled -CommandName Write-Error
        }
    }
}
