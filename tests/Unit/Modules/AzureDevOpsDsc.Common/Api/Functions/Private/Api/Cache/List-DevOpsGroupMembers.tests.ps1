$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsGroupMembers' {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview.1' }

    }

    Context 'When called with mandatory parameters' {

        # Inject expected parameters
        It 'Should return group members' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return @{
                    value = @(
                        @{principalName = 'user1@domain.com'}
                        @{principalName = 'user2@domain.com'}
                    )
                }
            }

            # Inject expected parameters
            $result = List-DevOpsGroupMembers -Organization 'MyOrg' -GroupDescriptor 'MyGroup'
            $result | Should -Not -BeNullOrEmpty

            # Validate the result
            $result[0].principalName | Should -Be 'user1@domain.com'
            $result[1].principalName | Should -Be 'user2@domain.com'

        }
    }

    Context 'When no members are found' {

        It 'Should return null' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod {
                return @{ value = $null }
            }

            $result = List-DevOpsGroupMembers -Organization 'MyOrg' -GroupDescriptor 'MyGroup'

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
            $result | Should -BeNullOrEmpty
        }

    }

    Context 'When optional ApiVersion parameter is provided' {

        It 'Should ignore Get-AzDevOpsApiVersion and use provided ApiVersion' {

            Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '5.0' }
            Mock -CommandName Invoke-AzDevOpsApiRestMethod { return $null }

            # Inject expected ApiVersion
            $null = List-DevOpsGroupMembers -Organization 'MyOrg' -GroupDescriptor 'MyGroup' -ApiVersion '6.0-preview.1'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0
        }

    }
}
