$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsGroups' -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'List-DevOpsGroups.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview' }

    }

    Context "When calling List-DevOpsGroups" {

        BeforeAll {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
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

        It 'should call Invoke-AzDevOpsApiRestMethod' {
            List-DevOpsGroups -Organization 'myOrg'
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
        }

        It 'should call Get-AzDevOpsApiVersion if no ApiVersion is specified' {
            List-DevOpsGroups -Organization 'myOrg'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }

        It 'should not call Get-AzDevOpsApiVersion if ApiVersion is specified' {
            List-DevOpsGroups -Organization 'myOrg' -ApiVersion '5.1'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0 -ParameterFilter {
                $Uri -eq 'https://dev.azure.com/myOrg/_apis/graph/groups?api-version=5.1'
            }
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
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { return @{ value = $null } }
        }

        It 'should return null if no groups are found' {
            $result = List-DevOpsGroups -Organization 'myOrg'
            $result | Should -BeNullOrEmpty
        }

    }

}
