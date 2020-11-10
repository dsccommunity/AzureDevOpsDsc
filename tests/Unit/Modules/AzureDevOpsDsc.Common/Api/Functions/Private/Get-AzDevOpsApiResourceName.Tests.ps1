
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:tag = @($($script:commandName -replace '-'))

    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        Context 'When input parameters are valid' {

            It 'Should not throw' {

                { Get-AzDevOpsApiResourceName } | Should -Not -Throw
            }

            It 'Should output a "System.String[]" type containing atleast 1 string value' {

                [System.String[]]$resourceNames = Get-AzDevOpsApiResourceName

                $resourceNames.Count | Should -BeGreaterThan 0
            }

            It 'Should output a "System.String[]" type containing no empty values' {

                [System.String[]]$resourceNames = Get-AzDevOpsApiResourceName

                [System.String]::Empty | Should -Not -BeIn $resourceNames
            }

            It 'Should output a "System.String[]" type containing no $null values' {

                [System.String[]]$resourceNames = Get-AzDevOpsApiResourceName

                $null | Should -Not -BeIn $resourceNames
            }

            It 'Should output a "System.String[]" type containing unique values' {

                [System.String[]]$resourceNames = Get-AzDevOpsApiResourceName

                $resourceNames.Count | Should -Be $($resourceNames | Select-Object -Unique).Count
            }

            # Create test cases for each 'ResourceName' returned by 'Get-AzDevOpsApiResourceName'
            [Hashtable[]]$testCasesResourceNames = Get-AzDevOpsApiResourceName |
                ForEach-Object {
                    @{
                        ResourceName = $_
                    }
                }

            It 'Should output values that are all validated by "Test-AzDevOpsApiResourceName" - "<ResourceName>"' -TestCases $testCasesResourceNames {
                param ([System.String]$ResourceName)

                Test-AzDevOpsApiResourceName -ResourceName $ResourceName -IsValid | Should -BeTrue
            }

        }

        Context "When input parameters are invalid" {

            # N/A - No parameters passed to function

        }
    }
}
