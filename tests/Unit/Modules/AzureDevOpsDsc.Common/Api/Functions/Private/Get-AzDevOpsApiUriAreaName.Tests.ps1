
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope $script:subModuleName {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {


            Context 'When called with no parameter values' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiUriAreaName } | Should -Not -Throw
                }

                It 'Should output a "System.String[]" type containing more than 1 value' {

                    [System.String[]]$uriAreaNames = Get-AzDevOpsApiUriAreaName

                    $uriAreaNames.Count | Should -BeGreaterThan 1
                }

                It 'Should output a "System.String[]" type containing no empty values' {

                    [System.String[]]$uriAreaNames = Get-AzDevOpsApiUriAreaName

                    [System.String]::Empty | Should -Not -BeIn $uriAreaNames
                }

                It 'Should output a "System.String[]" type containing no $null values' {

                    [System.String[]]$uriAreaNames = Get-AzDevOpsApiUriAreaName

                    $null | Should -Not -BeIn $uriAreaNames
                }

                It 'Should output a "System.String[]" type containing unique values' {

                    [System.String[]]$uriAreaNames = Get-AzDevOpsApiUriAreaName

                    $uriAreaNames.Count | Should -Be $($uriAreaNames | Select-Object -Unique).Count
                }

                # Create test cases for each 'UriResourceName' returned by 'Get-AzDevOpsApiUriAreaName'
                #[Hashtable[]]$testCasesUriResourceNames = Get-AzDevOpsApiUriAreaName |
                #    ForEach-Object {
                #        @{
                #            UriResourceName = $_
                #        }
                #    }

                # TODO: Uncomment this test once 'Test-AzDevOpsApiUriAreaName' function available
                #It 'Should output values that are all validated by "Test-AzDevOpsApiUriAreaName" - "<UriResourceName>"' -TestCases $testCasesUriResourceNames {
                #    param ([System.String]$UriResourceName)
                #
                #    Test-AzDevOpsApiUriAreaName -UriResourceName $UriResourceName -IsValid | Should -BeTrue
                #}
            }


            Context 'When called with a "ResourceName" parameter value' {

                It 'Should not throw - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    { Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName } | Should -Not -Throw
                }

                It 'Should output a "System.String[]" type containing exactly 1 value - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    [System.String[]]$uriAreaNames = Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName

                    $uriAreaNames.Count | Should -BeExactly 1
                }

                It 'Should output a "System.String" type that is not null or empty - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    [System.String]$uriResourceName = Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName

                    $uriResourceName | Should -Not -BeNullOrEmpty
                }

                It 'Should output a "System.String" type that is lowercase - "<ResourceName>"' -TestCases $testCasesValidResourceNames {
                    param ([System.String]$ResourceName)

                    [System.String]$uriResourceName = Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName

                    $uriResourceName | Should -BeExactly $($uriResourceName.ToLower())
                }
            }
        }


        Context "When input parameters are invalid" {

            Context 'When called with a "ResourceName" parameter value' {

                It 'Should throw - "<ResourceName>"' -TestCases $testCasesInvalidResourceNames {
                    param ([System.String]$ResourceName)

                    { Get-AzDevOpsApiUriAreaName -ResourceName $ResourceName } | Should -Throw
                }
            }
        }
    }
}
