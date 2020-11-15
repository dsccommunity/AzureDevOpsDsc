# Initialize tests for module function
. $PSScriptRoot\..\Classes.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:dscResourceName = Split-Path $PSScriptRoot -Leaf
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Classes\$script:dscResourceName\$script:dscResourceName.psm1"
    $script:tag = @($($script:commandName -replace '-'))


    Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {

        $testCasesValidRequiredActionWithFunctions = @(
            @{
                RequiredAction = 'Get'
            },
            @{
                RequiredAction = 'New'
            },
            @{
                RequiredAction = 'Set'
            },
            @{
                RequiredAction = 'Remove'
            },
            @{
                RequiredAction = 'Test'
            }
        )

        $testCasesValidRequiredActionWithoutFunctions = @(
            @{
                RequiredAction = 'Error'
            },
            @{
                RequiredAction = 'None'
            }
        )

        $testCasesInvalidRequiredActions = @(
            @{
                RequiredAction = 'SomethingInvalid'
            },
            @{
                RequiredAction = $null
            },
            @{
                RequiredAction = ''
            }
        )


        Context 'When called with valid "RequiredAction" values' {


            Context 'When "RequiredAction" value should have a related function' {

                It 'Should not throw - <RequiredAction>' -TestCases $testCasesValidRequiredActionWithFunctions {
                    param ([System.String]$RequiredAction)

                    $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBase]::new()

                    {$azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction)} | Should -Not -Throw
                }

                It 'Should return the correct, function name - "<RequiredAction>"' -TestCases $testCasesValidRequiredActionWithFunctions {
                    param ([System.String]$RequiredAction)

                    $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBase]::new()

                    $azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction) | Should -Be "$($RequiredAction)-AzDevOpsApiDscResourceBase"
                }
            }


            Context 'When "RequiredAction" value should not have a related function' {

                It 'Should not throw - <RequiredAction>' -TestCases $testCasesValidRequiredActionWithoutFunctions {
                    param ([System.String]$RequiredAction)

                    $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBase]::new()

                    {$azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction)} | Should -Not -Throw
                }

                It 'Should return the correct, function name - "<RequiredAction>"' -TestCases $testCasesValidRequiredActionWithoutFunctions {
                    param ([System.String]$RequiredAction)

                    $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBase]::new()

                    $azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction) | Should -BeNullOrEmpty
                }
            }
        }


        Context 'When called with invalid "RequiredAction" values' {

            It 'Should not throw - <RequiredAction>' -TestCases $testCasesInvalidRequiredActions {
                param ([System.String]$RequiredAction)

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBase]::new()

                {$azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction)} | Should -Throw
            }
        }
    }
}