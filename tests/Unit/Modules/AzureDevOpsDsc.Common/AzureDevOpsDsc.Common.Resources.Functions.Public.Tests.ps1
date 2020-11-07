
# Initialize tests
. $PSScriptRoot\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    Describe 'Resources\Functions' {

        $moduleName = 'AzureDevOpsDsc.Common'
        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesValidResourceNamesForDscResources = $testCasesValidResourceNames | Where-Object { $_.ResourceName -notin @('Operation')}

        Context "When evaluating 'AzureDevOpsDsc.Common' module functions" {
            BeforeAll {
                $moduleName = 'AzureDevOpsDsc.Common'
            }

            Context "When evaluating public, 'ExportedFunctions'" {

                BeforeAll {
                    [string[]]$exportedFunctionNames = Get-Command -Module $moduleName
                }

                $testCasesValidResourcePublicFunctionNames = Get-TestCase -ScopeName 'ResourcePublicFunctionName' -TestCaseName 'Valid'
                $testCasesValidDscResourcePublicFunctionNames = Get-TestCase -ScopeName 'DscResourcePublicFunctionName' -TestCaseName 'Valid'


                Context "When evaluating functions required for DSC resources" {

                    It "Should contain an exported, '<DscResourcePublicFunctionName>' function (specific to the 'ResourceName') - '<DscResourcePublicFunctionName>'" -TestCases $testCasesValidDscResourcePublicFunctionNames {
                        param ([string]$DscResourcePublicFunctionName)

                        $DscResourcePublicFunctionName | Should -BeIn $exportedFunctionNames
                   }

                   It "Should return a '<DscResourcePublicFunctionName>' function/command (specific to the 'ResourceName') from 'Get-Command' - '<DscResourcePublicFunctionName>'" -TestCases $testCasesValidDscResourcePublicFunctionNames {
                       param ([string]$DscResourcePublicFunctionName)

                       Get-Command -Module $moduleName -Name $DscResourcePublicFunctionName | Should -Not -BeNullOrEmpty
                   }

                }

                Context "When evaluating functions required for non-DSC resources" {

                    It "Should contain an exported, '<ResourcePublicFunctionName>' function (specific to the 'ResourceName') - '<ResourcePublicFunctionName>'" -TestCases $testCasesValidResourcePublicFunctionNames {
                        param ([string]$ResourcePublicFunctionName)

                        $ResourcePublicFunctionName | Should -BeIn $exportedFunctionNames
                    }

                    It "Should return a '<ResourcePublicFunctionName>' function/command (specific to the 'ResourceName') from 'Get-Command' - '<ResourcePublicFunctionName>'" -TestCases $testCasesValidResourcePublicFunctionNames {
                        param ([string]$ResourcePublicFunctionName)

                        Get-Command -Module $moduleName -Name $ResourcePublicFunctionName | Should -Not -BeNullOrEmpty
                    }

                }

            }

            Context "When evaluating private, module functions" {

                # TODO:
                # Should be a 'Test-<ResourceName>Id' function

            }

            $resourcesFunctionsPublicDirectoryPath = "$PSScriptRoot\..\..\..\..\source\Modules\$moduleName\Resources\Functions\Public"

            Context "When evaluating '$moduleName' module, function '.ps1' scripts directory ('$resourcesFunctionsPublicDirectoryPath')" {
                BeforeAll {
                    $moduleName = 'AzureDevOpsDsc.Common'
                    [string[]]$exportedFunctionNames = Get-Command -Module $moduleName
                    $resourcesFunctionsPublicDirectoryPath = "$PSScriptRoot\..\..\..\..\source\Modules\$moduleName\Resources\Functions\Public"
                }

                It "Should contain a 'Get-AzDevOps<ResourceName>.ps1' (GET) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNames {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath "Get-AzDevOps$ResourceName.ps1") | Should -BeTrue
                }

                It "Should contain a 'New-AzDevOps<ResourceName>.ps1' (NEW) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath "New-AzDevOps$ResourceName.ps1") | Should -BeTrue
                }

                It "Should contain a 'Set-AzDevOps<ResourceName>.ps1' (SET) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath "Set-AzDevOps$ResourceName.ps1") | Should -BeTrue
                }

                It "Should contain a 'Remove-AzDevOps<ResourceName>.ps1' (REMOVE) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath "Remove-AzDevOps$ResourceName.ps1") | Should -BeTrue
                }

                It "Should contain a 'Test-AzDevOps<ResourceName>.ps1' (TEST) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNames {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicDirectoryPath -ChildPath "Test-AzDevOps$ResourceName.ps1") | Should -BeTrue
                }

            }

            $resourcesFunctionsPublicTestsDirectoryPath = "$PSScriptRoot\Resources\Functions\Public"

            Context "When evaluating '$moduleName' module, public, function, tests directory ('$resourcesFunctionsPublicTestsDirectoryPath')" {
                BeforeAll {
                    $moduleName = 'AzureDevOpsDsc.Common'
                    [string[]]$exportedFunctionNames = Get-Command -Module $moduleName
                    $resourcesFunctionsPublicTestsDirectoryPath = "$PSScriptRoot\Resources\Functions\Public"
                }

                It "Should contain a 'Get-AzDevOps<ResourceName>.Tests.ps1' (GET) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNames {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath "Get-AzDevOps$ResourceName.Tests.ps1") | Should -BeTrue
                }

                It "Should contain a 'New-AzDevOps<ResourceName>.Tests.ps1' (NEW) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath "New-AzDevOps$ResourceName.Tests.ps1") | Should -BeTrue
                }

                It "Should contain a 'Set-AzDevOps<ResourceName>.Tests.ps1' (SET) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath "Set-AzDevOps$ResourceName.Tests.ps1") | Should -BeTrue
                }

                It "Should contain a 'Remove-AzDevOps<ResourceName>.Tests.ps1' (REMOVE) function script (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath "Remove-AzDevOps$ResourceName.Tests.ps1") | Should -BeTrue
                }

                It "Should contain a 'Test-AzDevOps<ResourceName>.ps1' (TEST) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNames {
                    param ([string]$ResourceName)

                    Test-Path $(Join-Path $resourcesFunctionsPublicTestsDirectoryPath -ChildPath "Test-AzDevOps$ResourceName.Tests.ps1") | Should -BeTrue
                }

            }

            Context "When evaluating '$moduleName' module, 'Get-AzDevOps...' (GET) functions" {

                Context "When evaluating function parameters" {

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with an 'ApiUri' parameter" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'ApiUri' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with an 'Pat' parameter" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'Pat' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        "$($ResourceName)Id" | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName").Name
                    }

                }

                Context "When evaluating function parameter aliases" {

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with an 'ApiUri' parameter, with a 'Uri' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'Uri' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'ApiUri' }).Aliases
                    }

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with an 'Pat' parameter, with a 'PersonalAccessToken' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'PersonalAccessToken' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'Pat' }).Aliases
                    }

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'ResourceId' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'ResourceId' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                    It "Should have a 'Get-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'Id' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'Id' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                }
            }



            Context "When evaluating '$moduleName' module, 'New-AzDevOps...' (NEW) functions" {

                Context "When evaluating function parameters" {

                    It "Should have a 'New-AzDevOps<ResourceName>' function with an 'ApiUri' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'ApiUri' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'New-AzDevOps<ResourceName>' function with an 'Pat' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Pat' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'New-AzDevOps<ResourceName>' function with no '<ResourceName>Id' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        "$($ResourceName)Id" | Should -Not -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName").Name
                    }

                }

                Context "When evaluating function parameter aliases" {

                    It "Should have a 'New-AzDevOps<ResourceName>' function with an 'ApiUri' parameter, with a 'Uri' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Uri' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'ApiUri' }).Aliases
                    }

                    It "Should have a 'New-AzDevOps<ResourceName>' function with an 'Pat' parameter, with a 'PersonalAccessToken' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'PersonalAccessToken' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'Pat' }).Aliases
                    }

                    It "Should have a 'New-AzDevOps<ResourceName>' function with no parameter with a 'ResourceId' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'ResourceId' | Should -Not -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName")).Aliases
                    }

                    It "Should have a 'New-AzDevOps<ResourceName>' function with no parameter, with a 'Id' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Id' | Should -Not -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "New-AzDevOps$ResourceName")).Aliases
                    }

                }
            }




            Context "When evaluating '$moduleName' module, 'Set-AzDevOps...' (SET) functions" {

                Context "When evaluating function parameters" {

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with an 'ApiUri' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'ApiUri' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with an 'Pat' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Pat' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        "$($ResourceName)Id" | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName").Name
                    }

                }

                Context "When evaluating function parameter aliases" {

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with an 'ApiUri' parameter, with a 'Uri' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Uri' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'ApiUri' }).Aliases
                    }

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with an 'Pat' parameter, with a 'PersonalAccessToken' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'PersonalAccessToken' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'Pat' }).Aliases
                    }

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'ResourceId' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'ResourceId' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                    It "Should have a 'Set-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'Id' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Id' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Set-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                }
            }




            Context "When evaluating '$moduleName' module, 'Remove-AzDevOps...' (REMOVE) functions" {

                Context "When evaluating function parameters" {

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with an 'ApiUri' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'ApiUri' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with an 'Pat' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Pat' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        "$($ResourceName)Id" | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName").Name
                    }

                }

                Context "When evaluating function parameter aliases" {

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with an 'ApiUri' parameter, with a 'Uri' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Uri' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'ApiUri' }).Aliases
                    }

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with an 'Pat' parameter, with a 'PersonalAccessToken' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'PersonalAccessToken' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'Pat' }).Aliases
                    }

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'ResourceId' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'ResourceId' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                    It "Should have a 'Remove-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'Id' alias" -TestCases $testCasesValidResourceNamesForDscResources {
                        param ([string]$ResourceName)

                        'Id' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Remove-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                }
            }


            Context "When evaluating '$moduleName' module, 'Test-AzDevOps...' (TEST) functions" {

                Context "When evaluating function parameters" {

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with an 'ApiUri' parameter" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'ApiUri' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with an 'Pat' parameter" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'Pat' | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName").Name
                    }

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        "$($ResourceName)Id" | Should -BeIn $(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName").Name
                    }

                }

                Context "When evaluating function parameter aliases" {

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with an 'ApiUri' parameter, with a 'Uri' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'Uri' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'ApiUri' }).Aliases
                    }

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with an 'Pat' parameter, with a 'PersonalAccessToken' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'PersonalAccessToken' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName") | Where-Object { $_.Name -eq 'Pat' }).Aliases
                    }

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'ResourceId' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'ResourceId' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                    It "Should have a 'Test-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'Id' alias" -TestCases $testCasesValidResourceNames {
                        param ([string]$ResourceName)

                        'Id' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Test-AzDevOps$ResourceName") | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                    }

                }
            }
        }

    }
}
