
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsProject' -Tag 'GetAzDevOpsProject' {

        Context 'When called with valid parameters' {
            BeforeAll {
                Mock -ModuleName $script:subModuleName Get-AzDevOpsApiObject {

                    $mockProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
                    $mockProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Valid'
                    $mockProjects = Join-TestCaseArray -Expand -TestCases $mockProjectIds, $mockProjectNames

                    return $mockProjects | ForEach-Object {
                        @{
                            id = $_.ProjectId
                            name = $_.ProjectName
                        }
                    }
                }
            }


            $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
            $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
            $testCasesValidApiUriPatCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUris, $testCasesValidPats

            $testCasesValidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Valid'
            $testCasesValidApiUriPatProjectNameCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesValidProjectNames

            $testCasesValidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
            $testCasesValidApiUriPatProjectIdCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesValidProjectIds


            Context 'When called with no "ProjectId" parameter and no "ProjectName" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat | Out-Null
                    Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

            }


            Context 'When called with no "ProjectId" parameter but with a "ProjectName" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                Context 'When a "Project" with supplied "ProjectName" parameter value exists' {

                    It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                        Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName | Out-Null
                        Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                    }
                }

                Context 'When a "Project" with supplied "ProjectName" parameter value does not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                        param ([string]$ApiUri, [string]$Pat)

                        $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName 'NonPresentProjectName'
                        $result | Should -Be $null
                    }
                }
            }


            Context 'When called with no "ProjectName" parameter but with a "ProjectId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                    { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                    $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                    Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId | Out-Null
                    Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

                Context 'When a "Project" with supplied "ProjectId" parameter value does not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                        param ([string]$ApiUri, [string]$Pat)

                        $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId '114bff8d-6169-45cf-b085-fe121267e7aa' # Non-present "ProjectId"
                        $result | Should -Be $null
                    }
                }

            }



        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            Context 'When called with invalid "Pat" parameter' {

                $testCasesEmptyPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Empty'
                $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'

                Context 'When called without "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { Get-AzDevOpsProject -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { Get-AzDevOpsProject -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { Get-AzDevOpsProject -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

                    }
                }
            }

            Context 'When called with invalid "ApiUri" parameter' {

                $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
                $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

                Context 'When called without "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { Get-AzDevOpsProject -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }
        }

    }

}
