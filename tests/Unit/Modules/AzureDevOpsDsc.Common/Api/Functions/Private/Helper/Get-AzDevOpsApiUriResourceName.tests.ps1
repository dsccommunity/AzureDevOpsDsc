Describe 'Get-AzDevOpsApiUriResourceName Tests' {

    BeforeEach {
        function Test-AzDevOpsApiResourceName {
            param ($ResourceName, $IsValid)
            return $true
        }
    }

    Context 'When ResourceName is provided' {
        It 'Should return correct URI-specific resource name for "Project"' {
            $result = Get-AzDevOpsApiUriResourceName -ResourceName 'Project'
            $result | Should -Be 'projects'
        }

        It 'Should return correct URI-specific resource name for "Operation"' {
            $result = Get-AzDevOpsApiUriResourceName -ResourceName 'Operation'
            $result | Should -Be 'operations'
        }
    }

    Context 'When ResourceName is not provided' {
        It 'Should return all URI-specific resource names' {
            $result = Get-AzDevOpsApiUriResourceName
            $expectedResult = @('operations', 'projects')
            $result | Should -Be $expectedResult
        }
    }

    Context 'When ResourceName is invalid' {
        BeforeEach {
            function Test-AzDevOpsApiResourceName {
                param ($ResourceName, $IsValid)
                return $false
            }
        }

        It 'Should not validate and throw an error' {
            { Get-AzDevOpsApiUriResourceName -ResourceName 'InvalidResource' } | Should -Throw
        }
    }
}

