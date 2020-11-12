
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


        # Mock functions called in function
        Mock Get-AzDevOpsApiResource {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesValidApiUriPatResourceNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidResourceNames) -Expand
        $testCasesValidApiUriPatResourceNames3 = $testCasesValidApiUriPatResourceNames | Select-Object -First 3

        $validApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Valid' -First 1
        $validResourceId = Get-TestCaseValue -ScopeName 'ResourceId' -TestCaseName 'Valid' -First 1

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatResourceNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidResourceNames) -Expand
        $testCasesInvalidApiUriPatResourceNames3 = $testCasesInvalidApiUriPatResourceNames | Select-Object -First 3

        $invalidApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Invalid' -First 1
        $invalidResourceId = Get-TestCaseValue -ScopeName 'ResourceId' -TestCaseName 'Invalid' -First 1


        Context 'When input parameters are valid' {


            Context 'When called with mandatory, "ApiUri", "Pat", "ResourceName" and "ResourceId" parameters' {

                Context 'When the "ResourceId" parameter value is invalid' {

                    It 'Should throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $invalidResourceId } | Should -Throw
                    }
                }

                Context 'When the "ResourceId" parameter value is valid' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId } | Should -Not -Throw
                    }

                    It 'Should return a type of "boolean" - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        $output = Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId

                        $output | Should -BeOfType [boolean]
                    }

                    It 'Should invoke "Get-AzDevOpsApiResource" only once - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        Mock Get-AzDevOpsApiResource {} -Verifiable

                        Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId | Out-Null

                        Assert-MockCalled 'Get-AzDevOpsApiResource' -Times 1 -Exactly -Scope 'It'
                    }


                    Context 'When the resource exists' {

                        It 'Should return $true - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                            param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                            Mock Get-AzDevOpsApiResource {
                                return [System.Management.Automation.PSObject[]]@(
                                    [System.Management.Automation.PSObject]@{
                                        id = '9a7ee4cf-7fa7-40e1-a3c0-1d0aacdaad92'
                                    },
                                    [System.Management.Automation.PSObject]@{
                                        id = 'db79312c-8231-48b7-9967-db1bad53c881'
                                    }
                                )
                            }

                            Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId | Should -BeTrue
                        }

                    }


                    Context 'When the resource does not exist' {

                        It 'Should return $false - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                            param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                            Mock Get-AzDevOpsApiResource {
                                return [System.Management.Automation.PSObject[]]@()
                            }

                            Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId | Should -BeFalse
                        }

                    }

                }

                Context "When also called with valid 'ApiVersion' parameter value" {

                    It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Test-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $validApiVersion -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId } | Should -Not -Throw
                    }
                }

                Context "When also called with invalid 'ApiVersion' parameter value" {

                    It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Test-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $invalidApiVersion -Pat $Pat -ResourceName $ResourceName -ResourceId $validResourceId } | Should -Throw
                    }
                }
            }
        }


        Context 'When input parameters are invalid' {

            Context 'When called with mandatory, "ApiUri", "Pat" and "ResourceName" parameters' {

                It 'Should throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesinvalidApiUriPatResourceNames {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    { Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName } | Should -Throw
                }
            }

        }
    }
}
