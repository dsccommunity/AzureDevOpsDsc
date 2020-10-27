<#
    .SYNOPSIS
        Automated unit test for helper functions in module AzureDevOpsDsc.Common.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

if (-not (Test-BuildCategory -Type 'Unit'))
{
    return
}

$script:dscModuleName = 'AzureDevOpsDsc'
$script:subModuleName = 'AzureDevOpsDsc.Common'

#region HEADER
Remove-Module -Name $script:subModuleName -Force -ErrorAction 'SilentlyContinue'

$script:parentModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'

$script:subModulePath = Join-Path -Path $script:subModulesFolder -ChildPath $script:subModuleName

Import-Module -Name $script:subModulePath -Force -ErrorAction 'Stop'
#endregion HEADER

# Loading mocked classes
#Add-Type -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs') -ChildPath 'SomeExampleMockedClass.cs')

InModuleScope $script:subModuleName {
    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsServicesUri' -Tag 'GetAzDevOpsServicesUri' {

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called with valid "Organisation" parameter' {

                $testCasesValidOrganizationNames = @(
                    @{
                        OrganizationName = 'Organisation1' },
                    @{
                        OrganizationName = 'Organisation-2' },
                    @{
                        OrganizationName = 'Organisation_3' }
                )

                It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    { Get-AzDevOpsServicesUri -OrganizationName $OrganizationName } | Should -Not -Throw
                }

                It 'Should return "https://dev.azure.com/<OrganizationName>/" - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    $result = Get-AzDevOpsServicesUri -OrganizationName $OrganizationName
                    $result | Should -Be "https://dev.azure.com/$OrganizationName/"
                }
            }


        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called with invalid "OrganizationName" parameter' {

                $testCasesInvalidOrganizationNames = @(
                    @{
                        OrganizationName = $null },
                    @{
                        OrganizationName = '' },
                    @{
                        OrganizationName = ' ' },
                    @{
                        OrganizationName = '%' },
                    @{
                        OrganizationName = 'Organization 0' }
                )

                It "Should throw - '<OrganizationName>'" -TestCases $testCasesInvalidOrganizationNames {
                    param ([string]$OrganizationName)

                    { Get-AzDevOpsServicesUri -OrganizationName $OrganizationName } | Should -Throw

                }
            }
        }

    }



    Describe 'AzureDevOpsDsc.Common\Test-AzDevOpsPat' -Tag 'TestAzDevOpsPat' {

        $testCasesValidPats = @(
            @{
                Pat = '1234567890123456789012345678901234567890123456789012' },
            @{
                Pat = '0987654321098765432109876543210987654321098765432109' },
            @{
                Pat = '0913uhuh3wedwndfwsni2242msfwneu254uhufs009oosfmikm34' }
        )

        $testCasesEmptyPats = @(
            @{
                Pat = $null },
            @{
                Pat = '' }
        )

        $testCasesInvalidPats = @(
            @{
                Pat = ' ' },
            @{
                Pat = 'a 1' },
            @{
                Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm3' },
            @{
                Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm34x' }
        )

        Context 'When called with valid parameters' {
            BeforeAll {
            }

            Context 'When called using "-IsValid" switch' {

                Context 'When called with valid "Pat" parameter' {

                    It 'Should not throw - "<Pat>"' -TestCases $testCasesValidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $true - "<Pat>"' -TestCases $testCasesValidPats {
                        param ([string]$Pat)

                        $result = Test-AzDevOpsPat -Pat $Pat -IsValid
                        $result | Should -Be $true
                    }
                }

                Context 'When called with invalid "Pat" parameter' {

                    It 'Should throw - "<Pat>"' -TestCases $testCasesEmptyPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid } | Should -Throw
                    }

                    It 'Should not throw - "<Pat>"' -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid } | Should -Not -Throw
                    }

                    It 'Should return $false - "<Pat>"' -TestCases $testCasesInvalidPats {
                        param ([string]$OrganizationName)

                        $result = Test-AzDevOpsPat -Pat $Pat -IsValid
                        $result | Should -Be $false
                    }
                }

            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called without using "-IsValid" switch' {

                Context 'When called with valid "Pat" parameter' {

                    It 'Should throw - "<Pat>"' -TestCases $testCasesValidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid:$false } | Should -Throw
                    }

                }

                Context 'When called with invalid "Pat" parameter' {

                    It 'Should throw - "<Pat>"' -TestCases $testCasesEmptyPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid:$false } | Should -Throw
                    }

                    It 'Should throw - "<Pat>"' -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { Test-AzDevOpsPat -Pat $Pat -IsValid:$false } | Should -Throw
                    }

                }

            }
        }

    }
}
