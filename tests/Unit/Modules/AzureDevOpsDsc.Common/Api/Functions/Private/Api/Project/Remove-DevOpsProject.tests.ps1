$currentFile = $MyInvocation.MyCommand.Path

Describe "Remove-DevOpsProject" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-DevOpsProject.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "5.1-preview.1" }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {}

    }

    Context "When removing a project" {

        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            $org = "MyOrganization"
            $projectId = "MyProject"
            $apiVersion = "5.1-preview.1"

            Remove-DevOpsProject -Organization $org -ProjectId $projectId

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
                $ApiUri -eq "https://dev.azure.com/MyOrganization/_apis/projects/MyProject?api-version=5.1-preview.1" -and
                $Method -eq "DELETE"
            }
        }

    }

    Context "When an exception occurs" {
        BeforeEach {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API call failed" }
            Mock -CommandName Write-Error -Verifiable
        }

        It "Should write an error message" {
            { Remove-DevOpsProject -Organization "MyOrganization" -ProjectId "MyProject" } | Should -Not -Throw
        }
    }
}
