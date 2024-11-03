$currentFile = $MyInvocation.MyCommand.Path

Describe "List-DevOpsProjects" -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'List-DevOpsProjects.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith {
            return "6.0"
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{
                value = @(
                    @{ name = "Project1"; id = "123" },
                    @{ name = "Project2"; id = "456" }
                )
            }
        }
    }

    It "Returns project list when called with valid organization name" {
        $result = List-DevOpsProjects -OrganizationName "TestOrg"
        $result | Should -Not -BeNullOrEmpty
        $result.Count | Should -Be 2
        $result[0].name | Should -Be "Project1"
        $result[1].name | Should -Be "Project2"
    }

    It "Returns null when no projects found" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ value = @() }
        }

        $result = List-DevOpsProjects -OrganizationName "TestOrg"
        $result | Should -BeNullOrEmpty
    }

}
