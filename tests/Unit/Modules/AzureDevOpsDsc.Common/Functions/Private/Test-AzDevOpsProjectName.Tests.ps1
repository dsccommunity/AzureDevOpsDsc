
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsProjectName' -Tag 'TestAzDevOpsProjectName' {

        $testCasesValidProjectNames = @(
            @{
                ProjectName = 'Project 0' },
            @{
                ProjectName = 'Project1' },
            @{
                ProjectName = 'Project-2' },
            @{
                ProjectName = 'Project_3' }
        )

        $testCasesEmptyProjectNames = @(
            @{
                ProjectName = $null },
            @{
                ProjectName = '' }
        )

        $testCasesInvalidProjectNames = @(
            @{
                ProjectName = ' ' },
            @{
                ProjectName = '%' }
        )

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "ProjectName" parameter' {

                    It 'Should not throw - "<ProjectName>"' -TestCases $testCasesValidProjectNames {
                        param ([string]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<ProjectName>"' -TestCases $testCasesValidProjectNames {
                        param ([string]$ProjectName)

                        $result = Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "ProjectName" parameter' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesEmptyProjectNames {
                        param ([string]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<ProjectName>"' -TestCases $testCasesInvalidProjectNames {
                        param ([string]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<ProjectName>"' -TestCases $testCasesInvalidProjectNames {
                        param ([string]$ProjectName)

                        $result = Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            $testCasesValidProjectNames = @(
                @{
                    ProjectName = 'Project1' },
                @{
                    ProjectName = 'Project-2' },
                @{
                    ProjectName = 'Project_3' }
            )

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "ProjectName" parameter' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesValidProjectNames {
                        param ([string]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "ProjectName" parameter' {

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesEmptyProjectNames {
                        param ([string]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<ProjectName>"' -TestCases $testCasesInvalidProjectNames {
                        param ([string]$ProjectName)

                        { Test-AzDevOpsProjectName -ProjectName $ProjectName -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
