$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsProcess' {

    BeforeAll {

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
