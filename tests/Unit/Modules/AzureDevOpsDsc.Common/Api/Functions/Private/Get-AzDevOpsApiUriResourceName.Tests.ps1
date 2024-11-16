
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with no parameter values' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiUriResourceName } | Should -Not -Throw
                }

                It 'Should output a "System.String[]" type containing more than 1 value' {

                    [System.String[]]$uriResourceNames = Get-AzDevOpsApiUriResourceName

                    $uriResourceNames.Count | Should -BeGreaterThan 1
                }

                It 'Should output a "System.String[]" type containing no empty values' {

                    [System.String[]]$uriResourceNames = Get-AzDevOpsApiUriResourceName

                    [System.String]::Empty | Should -Not -BeIn $uriResourceNames
                }

                It 'Should output a "System.String[]" type containing no $null values' {

                    [System.String[]]$uriResourceNames = Get-AzDevOpsApiUriResourceName

                    $null | Should -Not -BeIn $uriResourceNames
                }

                It 'Should output a "System.String[]" type containing unique values' {

                    [System.String[]]$uriResourceNames = Get-AzDevOpsApiUriResourceName

                    $uriResourceNames.Count | Should -Be $($uriResourceNames | Select-Object -Unique).Count
                }

                # Create test cases for each 'UriResourceName' returned by 'Get-AzDevOpsApiUriResourceName'
                #[Hashtable[]]$testCasesUriResourceNames = Get-AzDevOpsApiUriResourceName |
                #    ForEach-Object {
                #        @{
                #            UriResourceName = $_
                #        }
                #    }

                # TODO: Uncomment this test once 'Test-AzDevOpsApiUriResourceName' function available
                #It 'Should output values that are all validated by "Test-AzDevOpsApiUriResourceName" - "<UriResourceName>"' -TestCases $testCasesUriResourceNames {
                #    param ([System.String]$UriResourceName)
                #
                #    Test-AzDevOpsApiUriResourceName -UriResourceName $UriResourceName -IsValid | Should -BeTrue
                #}
            }


            Context 'When called with a "ResourceName" parameter value' {

                It 'Should not throw - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    { Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName } | Should -Not -Throw
                }

                It 'Should output a "System.String[]" type containing exactly 1 value - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    [System.String[]]$uriResourceNames = Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName

                    $uriResourceNames.Count | Should -BeExactly 1
                }

                It 'Should output a "System.String" type that is not null or empty - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    [System.String]$uriResourceName = Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName

                    $uriResourceName | Should -Not -BeNullOrEmpty
                }

                It 'Should output a "System.String" type that is lowercase - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    [System.String]$uriResourceName = Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName

                    $uriResourceName | Should -BeExactly $($uriResourceName.ToLower())
                }
            }
        }


        Context "When input parameters are invalid" {

            Context 'When called with a "ResourceName" parameter value' {

                It 'Should throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                    param ([System.String]$ResourceName)

                    { Get-AzDevOpsApiUriResourceName -ResourceName $ResourceName } | Should -Throw
                }
            }
        }
    }
}
