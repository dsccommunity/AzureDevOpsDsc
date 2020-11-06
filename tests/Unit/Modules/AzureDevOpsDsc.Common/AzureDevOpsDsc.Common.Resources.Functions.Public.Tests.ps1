
# Initialize tests
. $PSScriptRoot\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    Describe 'DSCClassResources\AzDevOpsApiDscResource' -Tag 'AzDevOpsApiDscResource' {

        $moduleName = 'AzureDevOpsDsc.Common'
        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesValidResourceNamesForDscResources = $testCasesValidResourceNames | Where-Object { $_.ResourceName -notin @('Operation')}

        Context "When evaluating '$moduleName' module 'ExportedFunctions'" {
            BeforeAll {
                $moduleName = 'AzureDevOpsDsc.Common'
                [string[]]$exportedFunctionNames = Get-Command -Module $moduleName
            }

            It "Should contain an exported, 'Get-AzDevOps<ResourceName>' (GET) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNames {
                param ([string]$ResourceName)

                "Get-AzDevOps$ResourceName" | Should -BeIn $exportedFunctionNames
            }

            It "Should contain an exported, 'New-AzDevOps<ResourceName>' (NEW) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                param ([string]$ResourceName)

                "New-AzDevOps$ResourceName" | Should -BeIn $exportedFunctionNames
            }

            It "Should contain an exported, 'Set-AzDevOps<ResourceName>' (SET) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                param ([string]$ResourceName)

                "Set-AzDevOps$ResourceName" | Should -BeIn $exportedFunctionNames
            }

            It "Should contain an exported, 'Remove-AzDevOps<ResourceName>' (REMOVE) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNamesForDscResources {
                param ([string]$ResourceName)

                "Remove-AzDevOps$ResourceName" | Should -BeIn $exportedFunctionNames
            }

            It "Should contain an exported, 'Test-AzDevOps<ResourceName>' (TEST) function (specific to the 'ResourceName') - '<ResourceName>'" -TestCases $testCasesValidResourceNames {
                param ([string]$ResourceName)

                "Test-AzDevOps$ResourceName" | Should -BeIn $exportedFunctionNames
            }

        }


        $resourcesFunctionsPublicDirectoryPath = "$PSScriptRoot\Resources\Functions\Public"

        Context "When evaluating '$moduleName' module, function '.ps1' scripts directory ('$resourcesFunctionsPublicDirectoryPath')" {
            BeforeAll {
                $moduleName = 'AzureDevOpsDsc.Common'
                [string[]]$exportedFunctionNames = Get-Command -Module $moduleName
                $resourcesFunctionsPublicDirectoryPath = "$PSScriptRoot\Resources\Functions\Public"
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

                    'PersonalAccessToken' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName").Name | Where-Object { $_.Name -eq 'Pat' }).Aliases
                }

                It "Should have a 'Get-AzDevOps<ResourceName>' function with a/an '<ResourceName>Id' parameter, with a 'ResourceId' alias" -TestCases $testCasesValidResourceNames {
                    param ([string]$ResourceName)

                    'ResourceId' | Should -BeIn $($(Get-CommandParameter -ModuleName $moduleName -CommandName "Get-AzDevOps$ResourceName").Name | Where-Object { $_.Name -eq "$($ResourceName)Id" }).Aliases
                }

            }
        }

    }
}
