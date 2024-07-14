
Describe 'Get-AzDevOpsApiUriAreaName' {
    Mock -CommandName Test-AzDevOpsApiResourceName -MockWith { $true }

    Context 'When no ResourceName is provided' {
        It 'Returns all unique area names' {
            $result = Get-AzDevOpsApiUriAreaName
            $expected = @('core', 'profile')

            $result | Should -Be $expected
        }
    }

    Context 'When a valid ResourceName is provided' {
        It 'Returns the correct area name for Project' {
            $result = Get-AzDevOpsApiUriAreaName -ResourceName 'Project'
            $result | Should -Be 'core'
        }

        It 'Returns the correct area name for Operation' {
            $result = Get-AzDevOpsApiUriAreaName -ResourceName 'Operation'
            $result | Should -Be 'core'
        }

        It 'Returns the correct area name for Profile' {
            $result = Get-AzDevOpsApiUriAreaName -ResourceName 'Profile'
            $result | Should -Be 'profile'
        }
    }

    Context 'When an invalid ResourceName is provided' {
        It 'Throws an error' {
            Mock -CommandName Test-AzDevOpsApiResourceName -MockWith { $false }
            { Get-AzDevOpsApiUriAreaName -ResourceName 'InvalidResourceName' } | Should -Throw
        }
    }
}

