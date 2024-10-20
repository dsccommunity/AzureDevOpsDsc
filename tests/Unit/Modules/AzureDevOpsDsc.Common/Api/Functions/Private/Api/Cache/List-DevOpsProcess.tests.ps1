$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsProcess' -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'List-DevOpsProcess.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "6.0" }

    }

    # Test cases
    Context 'When called with mandatory parameters' {

        # Validate the call
        It 'should call Invoke-AzDevOpsApiRestMethod' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return @{ value = @() }
            }

            List-DevOpsProcess -Organization "MyOrganization"
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $apiUri -eq "https://dev.azure.com/MyOrganization/_apis/process/processes?api-version=6.0" -and
                $Method -eq 'Get'
            } -Times 1
        }

        it "should change the url when the api-version changes" {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return @{ value = @() }
            }

            Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "6.1" }

            List-DevOpsProcess -Organization "MyOrganization"
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $apiUri -eq "https://dev.azure.com/MyOrganization/_apis/process/processes?api-version=6.1" -and
                $Method -eq 'Get'
            } -Times 1
        }

        # Validate the call
        It 'should return the process groups' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return @{
                    value = @(
                        @{ id = "1"; name = "Agile" }
                        @{ id = "2"; name = "Scrum" }
                    )
                }
            }

            # Validate the result
            $result = List-DevOpsProcess -Organization "MyOrganization"
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2

            # Validate the first process
            $result.id[0] | Should -Be "1"
            $result.name[0] | Should -Be "Agile"
            $result.id[1] | Should -Be "2"
            $result.name[1] | Should -Be "Scrum"

        }
    }

    Context 'When no processes are returned' {

        It 'should return $null' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { return @{ value = $null } }

            $result = List-DevOpsProcess -Organization "MyOrganization"
            $result | Should -Be $null
        }
    }

}
