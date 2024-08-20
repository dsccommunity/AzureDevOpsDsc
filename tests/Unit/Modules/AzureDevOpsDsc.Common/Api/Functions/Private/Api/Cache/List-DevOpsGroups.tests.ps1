$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsGroups' {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview' }

    }

    Context "When calling List-DevOpsGroups" {

        BeforeAll {
            Mock -CommandName Invoke-APIRestMethod -MockWith {
                return @{
                    value = @(
                        @{
                            displayName = 'Group1'
                        },
                        @{
                            displayName = 'Group2'
                        }
                    )
                }
            }
        }

        It 'should call Invoke-APIRestMethod' {
            List-DevOpsGroups -Organization 'myOrg'
            Assert-MockCalled Invoke-APIRestMethod -Exactly 1
        }

        It 'should call Get-AzDevOpsApiVersion if no ApiVersion is specified' {
            List-DevOpsGroups -Organization 'myOrg'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }

        It 'should not call Get-AzDevOpsApiVersion if ApiVersion is specified' {
            List-DevOpsGroups -Organization 'myOrg' -ApiVersion '5.1'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0
        }

        It 'should return group data' {
            $result = List-DevOpsGroups -Organization 'myOrg'
            $result.Count | Should -Be 2
            $result[0].displayName | Should -Be 'Group1'
            $result[1].displayName | Should -Be 'Group2'
        }

    }

    Context "When no groups are found" {

        BeforeAll {
            Mock -CommandName Invoke-APIRestMethod -MockWith { return @{ value = $null } }
        }

        It 'should return null if no groups are found' {
            $result = List-DevOpsGroups -Organization 'myOrg'
            $result | Should -BeNullOrEmpty
        }

    }

}
