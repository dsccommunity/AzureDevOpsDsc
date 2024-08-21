$currentFile = $MyInvocation.MyCommand.Path

Describe "Update-DevOpsProject" {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{ statusCode = 200; content = "Success" }
        }

    }

    Context "When all mandatory parameters are provided" {

        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {

            $organization = "TestOrg"
            $projectId = "TestProject"
            $apiVersion = "6.0"

            $params = @{
                Organization = $organization
                ProjectId = $projectId
                ApiVersion = $apiVersion
            }

            $result = Update-DevOpsProject @params

            # Assert that the mock was called with expected parameters
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly -Scope It -ParameterFilter {
                $ApiUri -eq "https://dev.azure.com/TestOrg/_apis/projects/TestProject?api-version=6.0" -and
                $Method -eq 'PATCH'
            }

            # Assert that the result is as expected
            $result.statusCode | Should -Be 200
        }
    }

    Context "When optional parameters are provided" {

        It "Should include optional parameters in the request body" {
            $organization = "TestOrg"
            $projectId = "TestProject"
            $projectDescription = "Test Description"
            $visibility = "private"
            $apiVersion = "6.0"

            $params = @{
                Organization = $organization
                ProjectId = $projectId
                ProjectDescription = $projectDescription
                Visibility = $visibility
                ApiVersion = $apiVersion
            }

            $result = Update-DevOpsProject @params

            # Assert that the mock was called with expected parameters
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly -Scope It -ParameterFilter {
                $Body -match '"description": "Test Description"' -and
                $Body -match '"visibility": "private"'
            }

            # Assert that the result is as expected
            $result.statusCode | Should -Be 200
        }
    }

    Context "When an error occurs during API call" {

        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            throw "API call failed"
        }

        It "Should catch the error and write an error message" {

            Mock -CommandName Write-Error -Verifiable

            $organization = "TestOrg"
            $projectId = "TestProject"
            $apiVersion = "6.0"

            $params = @{
                Organization = $organization
                ProjectId = $projectId
                ApiVersion = $apiVersion
            }

            { Update-DevOpsProject @params } | Should -Not -Throw

        }
    }
}
