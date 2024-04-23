
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Valid'
        $testCasesInvalidApiVersions = Get-TestCase -ScopeName 'ApiVersion' -TestCaseName 'Invalid'
        $supportedApiVersion = '6.0'


        Context 'When input parameters are valid' {


            Context 'When called with no parameter values' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiVersion } | Should -Not -Throw
                }

                # Note: Only applicable if only 1 'ApiVersion' is supported
                It "Should output a 'System.String' type containing an 'ApiVersion' of '$supportedApiVersion'" {

                    [System.String]$apiVersion = Get-AzDevOpsApiVersion

                    $apiVersion | Should -BeExactly $supportedApiVersion
                }

                # Note: Only applicable if only 1 'ApiVersion' is supported
                It 'Should output a "System.String[]" type containing no empty values' {

                    [System.String[]]$apiVersions = Get-AzDevOpsApiVersion

                    [System.String]::Empty | Should -Not -BeIn $apiVersions
                }

                It 'Should output a "System.String[]" type containing no $null values' {

                    [System.String[]]$apiVersions = Get-AzDevOpsApiVersion

                    $null | Should -Not -BeIn $apiVersions
                }

                It 'Should output a "System.String[]" type containing unique values' {

                    [System.String[]]$apiVersions = Get-AzDevOpsApiVersion

                    $apiVersions.Count | Should -Be $($apiVersions | Select-Object -Unique).Count
                }

                #Create test cases for each 'ApiVersion' returned by 'Get-AzDevOpsApiVersion'
                [Hashtable[]]$testCasesApiVersions = Get-AzDevOpsApiVersion |
                   ForEach-Object {
                       @{
                           ApiVersion = $_
                       }
                   }

                It 'Should output values that are all validated by "Test-AzDevOpsApiVersion" - "<ApiVersion>"' -TestCases $testCasesApiVersions {
                   param ([System.String]$ApiVersion)

                   Test-AzDevOpsApiVersion -ApiVersion $ApiVersion -IsValid | Should -BeTrue
                }

                It 'Should output values that are in the valid, "ApiVersion" test cases - "<ApiVersion>"' -TestCases $testCasesValidApiVersions {
                    param ([System.String]$ApiVersion)

                    $ApiVersion | Should -BeIn $([System.String[]]$(Get-AzDevOpsApiVersion))
                }

                It 'Should not output values that are in the invalid, "ApiVersion" test cases - "<ApiVersion>"' -TestCases $testCasesInvalidApiVersions {
                    param ([System.String]$ApiVersion)

                    $ApiVersion | Should -Not -BeIn $([System.String[]]$(Get-AzDevOpsApiVersion))
                }
            }


            Context 'When called with the "Default" switch parameter' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiVersion -Default } | Should -Not -Throw
                }

                It 'Should output a "System.String[]" type containing exactly 1 value' {

                    [System.String[]]$apiVersions = Get-AzDevOpsApiVersion -Default

                    $apiVersions.Count | Should -BeExactly 1
                }

                It 'Should output a "System.String" type that is not null or empty' {

                    [System.String]$uriResourceName = Get-AzDevOpsApiVersion -Default

                    $uriResourceName | Should -Not -BeNullOrEmpty
                }

                It "Should output a 'System.String' type containing an 'ApiVersion' of '$supportedApiVersion'" {

                    [System.String]$apiVersion = Get-AzDevOpsApiVersion -Default

                    $apiVersion | Should -BeExactly $supportedApiVersion
                }
            }


            # Effectively identical to 'When called with no parameter values' context (with test cases above)
            Context 'When called with a "Default" switch parameter value of $false' {

                It 'Should not throw' {

                    { Get-AzDevOpsApiVersion -Default:$false } | Should -Not -Throw
                }
            }
        }


        Context "When input parameters are invalid" {

            # N/A - Only the 'Default' switch parameter on this function/commands

        }
    }
}
