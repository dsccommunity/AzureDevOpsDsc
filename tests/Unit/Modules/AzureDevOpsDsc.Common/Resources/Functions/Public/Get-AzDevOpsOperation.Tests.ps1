
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Public\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Resources\Functions\Public\$script:commandName" -Tag $script:tag {

        # Mock functions called in function
        Mock Get-AzDevOpsApiResource {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidApiUriPats = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats) -Expand
        $testCasesValidApiUriPats3 = $testCasesValidApiUriPats | Select-Object -First 3

        $testCasesValidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Valid'
        $testCasesValidApiUriPatOperationIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidOperationIds) -Expand
        $testCasesValidApiUriPatOperationIds3 = $testCasesValidApiUriPatOperationIds | Select-Object -First 3

        $validOperationIdThatExists = '3456bc8e-0c47-440e-bd49-6db608abb461'
        $validOperationIdThatDoesNotExist = '9b03d056-cd1c-4f51-b007-5d1d896e38f0'


        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPats = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats) -Expand
        $testCasesInvalidApiUriPats3 = $testCasesInvalidApiUriPats | Select-Object -First 3

        $testCasesInvalidOperationIds = Get-TestCase -ScopeName 'OperationId' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatOperationIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidOperationIds) -Expand
        $testCasesInvalidApiUriPatOperationIds3 = $testCasesInvalidApiUriPatOperationIds | Select-Object -First 3




        Context 'When input parameters are valid' {


            Context 'When called with mandatory "ApiUri" and "Pat" parameters' {

                It 'Should not throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat } | Should -Not -Throw
                }

                It 'Should invoke "Get-AzDevOpsApiResource" only once - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                    param ([string]$ApiUri, [string]$Pat)

                    Mock Get-AzDevOpsApiResource {} -Verifiable

                    Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat | Out-Null

                    Assert-MockCalled 'Get-AzDevOpsApiResource' -Times 1 -Exactly -Scope 'It'
                }

                Context 'When "Operation" resources do exist' {

                    It 'Should return same number of "Operation" resources as "Get-AzDevOpsApiResource" does - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                        param ([string]$ApiUri, [string]$Pat)

                        Mock Get-AzDevOpsApiResource {
                            return @(
                                $([System.Management.Automation.PSObject]@{
                                    id = '6c5cfb48-ef00-4965-9e8b-8890cea541b0'
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = '3456bc8e-0c47-440e-bd49-6db608abb461' # Same as $validOperationIdThatExists
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = 'a058fe7e-b336-4d7f-9131-59ab9640bef4'
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = '9b8dc0c7-36cb-45aa-8177-945583fe253c'
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = '19aea70c-1339-44b1-b7a3-9d8e6c421a74'
                                })
                            )
                        }

                        $operations = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat

                        $operations.Count | Should -Be $($(Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Operation').Count)
                    }

                }

                Context 'When "Operation" resources do not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                        param ([string]$ApiUri, [string]$Pat)

                        $operations = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat
                        $operations | Should -BeNullOrEmpty
                    }

                    It 'Should return no "Operation" resources - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                        param ([string]$ApiUri, [string]$Pat)

                        [System.Management.Automation.PSObject[]]$operations = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat
                        $operations.Count | Should -Be 0
                    }
                }


                Context 'When also called with optional, "OperationId" parameter' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId } | Should -Not -Throw
                    }

                    It 'Should invoke "Get-AzDevOpsApiResource" only once - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIds3 {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        Mock Get-AzDevOpsApiResource {} -Verifiable

                        Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId | Out-Null

                        Assert-MockCalled 'Get-AzDevOpsApiResource' -Times 1 -Exactly -Scope 'It'
                    }


                    Context 'When an "Operation" resource exists' {

                        Mock Get-AzDevOpsApiResource {
                            return @(
                                $([System.Management.Automation.PSObject]@{
                                    id = '6c5cfb48-ef00-4965-9e8b-8890cea541b0'
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = '3456bc8e-0c47-440e-bd49-6db608abb461' # Same as $validOperationIdThatExists
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = 'a058fe7e-b336-4d7f-9131-59ab9640bef4'
                                })
                            )
                        }

                        It 'Should return exactly 1 "Operation" resource - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            [System.Management.Automation.PSObject[]]$operations = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $validOperationIdThatExists
                            $operations.Count | Should -Be 1
                        }

                        It 'Should return exactly 1 "Operation" resource with identical "id" - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            [System.Management.Automation.PSObject]$operation = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $validOperationIdThatExists

                            $operation.id | Should -Be $validOperationIdThatExists
                        }

                    }


                    Context 'When an "Operation" resource does not exist' {

                        It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            $operations = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $validOperationIdThatDoesNotExist
                            $operations | Should -BeNullOrEmpty
                        }

                        It 'Should return no "Operation" resources - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            [System.Management.Automation.PSObject[]]$operations = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $validOperationIdThatDoesNotExist
                            $operations.Count | Should -Be 0
                        }
                    }
                }
            }
        }


        Context 'When input parameters are invalid' {


            Context 'When called with invalid, mandatory "ApiUri" and "Pat" parameters' {

                It 'Should throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesInvalidApiUriPats {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat } | Should -Throw
                }


                Context 'When also called with invalid, optional, "OperationId" parameter' {

                    It 'Should throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesInvalidApiUriPatOperationIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                        { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId } | Should -Throw
                    }
                }

            }

        }
    }
}
