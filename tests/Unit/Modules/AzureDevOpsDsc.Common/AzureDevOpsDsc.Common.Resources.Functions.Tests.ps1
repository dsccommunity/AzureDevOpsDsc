
# Initialize tests
. $PSScriptRoot\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    Describe 'Resources\Functions' {

        $moduleName = 'AzureDevOpsDsc.Common'
        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesValidResourceNamesForDscResources = $testCasesValidResourceNames | Where-Object { $_.ResourceName -notin @('Operation')}

        Context "When evaluating 'AzureDevOpsDsc.Common' module functions" {
            BeforeEach {
                $moduleName = 'AzureDevOpsDsc.Common'
            }

            Context "When evaluating public, 'ExportedFunctions'" {

                BeforeEach {
                    [string[]]$exportedFunctionNames = Get-Command -Module $moduleName

                    $resourcesFunctionsPublicDirectoryPath = "$PSScriptRoot\..\..\..\..\source\Modules\$moduleName\Resources\Functions\Public"
                    $resourcesFunctionsPublicTestsDirectoryPath = "$PSScriptRoot\Resources\Functions\Public"
                }


                $testCasesValidResourcePublicFunctionNames = Get-TestCase -ScopeName 'ResourcePublicFunctionName' -TestCaseName 'Valid'
                $testCasesValidDscResourcePublicFunctionNames = Get-TestCase -ScopeName 'DscResourcePublicFunctionName' -TestCaseName 'Valid'

                $testCasesValidApiResourcePublicFunctionRequiredParameterNames = Get-TestCase -ScopeName 'ApiResourcePublicFunctionRequiredParameterName' -TestCaseName 'Valid'

                $testCasesValidDscResourcePublicFunctionRequiredParameterNames = Join-TestCaseArray -Expand -TestCaseArray @(
                    $testCasesValidDscResourcePublicFunctionNames,
                    $testCasesValidApiResourcePublicFunctionRequiredParameterNames
                )

                $testCasesValidApiResourcePublicFunctionMandatoryParameterNames = Get-TestCase -ScopeName 'ApiResourcePublicFunctionMandatoryParameterName' -TestCaseName 'Valid'

                $testCasesValidDscResourcePublicFunctionMandatoryParameterNames = Join-TestCaseArray -Expand -TestCaseArray @(
                    $testCasesValidDscResourcePublicFunctionNames,
                    $testCasesValidApiResourcePublicFunctionMandatoryParameterNames
                )

                $testCasesValidParameterAliasNames = Get-TestCase -ScopeName 'ParameterAliasName' -TestCaseName 'Valid'



                Context "When evaluating all public, functions" {


                    # Note: $testCasesExportedFunctionNames contains all exported functions in the module

                    #It "Does not return a null value when 'Get-Command' is called - '<ExportedFunctionName>'" -TestCases $testCasesExportedFunctionNames {
                    #    param ([string]$ExportedFunctionName)
                    #
                    #    Get-Command "$ExportedFunctionName" | Should -Not -BeNullOrEmpty
                    #}

                    It "When evaluating function parameter, aliases required for DSC resource functions" {
                        # TODO
                    }

                }



                Context "When evaluating all public, functions required for DSC resources" {

                    It "Should contain an exported, '<DscResourcePublicFunctionName>' function (specific to the 'ResourceName') - '<DscResourcePublicFunctionName>'" -TestCases $testCasesValidDscResourcePublicFunctionNames {
                        param ([string]$DscResourcePublicFunctionName)

                        $DscResourcePublicFunctionName | Should -BeIn $exportedFunctionNames
                    }

                    It "Should return a '<DscResourcePublicFunctionName>' function/command (specific to the 'ResourceName') from 'Get-Command' - '<DscResourcePublicFunctionName>'" -TestCases $testCasesValidDscResourcePublicFunctionNames {
                        param ([string]$DscResourcePublicFunctionName)

                        Get-Command -Module $moduleName -Name $DscResourcePublicFunctionName | Should -Not -BeNullOrEmpty
                    }

                    It "Should have a '<DscResourcePublicFunctionName>' script ('.ps1') file (specific to the 'ResourceName') - '<DscResourcePublicFunctionName>'" -TestCases $testCasesValidDscResourcePublicFunctionNames {
                        param ([string]$DscResourcePublicFunctionName)

                        $functionScriptPath = Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath $($DscResourcePublicFunctionName + ".ps1")
                        Test-Path $functionScriptPath | Should -BeTrue
                    }

                    It "Should have a '<DscResourcePublicFunctionName>' test fixture/script ('.Tests.ps1') file (specific to the 'ResourceName') - '<DscResourcePublicFunctionName>'" -TestCases $testCasesValidDscResourcePublicFunctionNames {
                        param ([string]$DscResourcePublicFunctionName)

                        $functionTestsScriptPath = Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath $($DscResourcePublicFunctionName + ".Tests.ps1")
                        Test-Path $functionTestsScriptPath | Should -BeTrue
                    }

                    Context "When evaluating function parameters required for DSC resource functions" {

                        It "Should have a '<DscResourcePublicFunctionName>' function with required, '<ApiResourcePublicFunctionRequiredParameterName>' parameter - '<DscResourcePublicFunctionName>', '<ApiResourcePublicFunctionRequiredParameterName>'" -TestCases $testCasesValidDscResourcePublicFunctionRequiredParameterNames {
                            param ([string]$DscResourcePublicFunctionName,
                                   [string]$ApiResourcePublicFunctionRequiredParameterName)

                            $ApiResourcePublicFunctionRequiredParameterName |
                                Should -BeIn $((Get-CommandParameter -CommandName $DscResourcePublicFunctionName -ModuleName $moduleName).Name)
                        }

                        Context "When evaluating function parameters required for DSC resource functions that must be 'Mandatory'" {

                            It "Should have a '<DscResourcePublicFunctionName>' function with required (and 'Mandatory'), '<ApiResourcePublicFunctionMandatoryParameterName>' parameter - '<DscResourcePublicFunctionName>', '<ApiResourcePublicFunctionMandatoryParameterName>'" -TestCases $testCasesValidDscResourcePublicFunctionMandatoryParameterNames {
                                param ([string]$DscResourcePublicFunctionName,
                                    [string]$ApiResourcePublicFunctionMandatoryParameterName)

                                $ApiResourcePublicFunctionMandatoryParameterName |
                                    Should -BeIn $(((Get-CommandParameterSetParameter -CommandName $DscResourcePublicFunctionName -ModuleName $moduleName) | Where-Object { $_.IsMandatory -eq 1 }).Name)
                            }
                        }
                    }
                }

                Context "When evaluating all public, functions required for non-DSC resources" {

                    It "Should contain an exported, '<ResourcePublicFunctionName>' function (specific to the 'ResourceName') - '<ResourcePublicFunctionName>'" -TestCases $testCasesValidResourcePublicFunctionNames {
                        param ([string]$ResourcePublicFunctionName)

                        $ResourcePublicFunctionName | Should -BeIn $exportedFunctionNames
                    }

                    It "Should return a '<ResourcePublicFunctionName>' function/command (specific to the 'ResourceName') from 'Get-Command' - '<ResourcePublicFunctionName>'" -TestCases $testCasesValidResourcePublicFunctionNames {
                        param ([string]$ResourcePublicFunctionName)

                        Get-Command -Module $moduleName -Name $ResourcePublicFunctionName | Should -Not -BeNullOrEmpty
                    }

                    It "Should have a '<ResourcePublicFunctionName>' script ('.ps1') file (specific to the 'ResourceName') - '<ResourcePublicFunctionName>'" -TestCases $testCasesValidResourcePublicFunctionNames {
                        param ([string]$ResourcePublicFunctionName)

                        $functionScriptPath = Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath $($ResourcePublicFunctionName + ".ps1")
                        Test-Path $functionScriptPath | Should -BeTrue
                    }

                    It "Should have a '<ResourcePublicFunctionName>' test fixture/script ('.Tests.ps1') file (specific to the 'ResourceName') - '<ResourcePublicFunctionName>'" -TestCases $testCasesValidResourcePublicFunctionNames {
                        param ([string]$ResourcePublicFunctionName)

                        $functionTestsScriptPath = Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath $($ResourcePublicFunctionName + ".Tests.ps1")
                        Test-Path $functionTestsScriptPath | Should -BeTrue
                    }

                }

            }

            Context "When evaluating private, module functions" {

                # TODO:
                # Should be a 'Test-<ResourceName>Id' function present

            }
        }

    }
}
