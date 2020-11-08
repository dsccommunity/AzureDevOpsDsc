
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\New-AzDevOpsProject' -Tag 'NewAzDevOpsProject' {

        Context 'When called with valid parameters' {
            BeforeAll {
                $mockProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
                $mockProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Valid'
                $mockProjects = Join-TestCaseArray -Expand -TestCases $mockProjectIds, $mockProjectNames

                Mock -ModuleName $script:subModuleName New-AzDevOpsApiResource -Verifiable {
                }

                Mock -ModuleName $script:subModuleName Get-AzDevOpsProject -Verifiable {
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

            $testCasesInvalidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Invalid'
            $testCasesValidApiUriPatInvalidProjectNameCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesInvalidProjectNames


            Context 'When called with a "ProjectName" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    { New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    $result = New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "New-AzDevOpsApiResource" function exactly once - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName | Out-Null
                    Should -Invoke New-AzDevOpsApiResource -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

                Context 'When a "Project" with supplied "ProjectName" parameter value already exists' {

                    BeforeEach {
                        Mock -ModuleName $script:subModuleName New-AzDevOpsApiResource -Verifiable {
                            throw "Already exists"
                        }
                    }

                    It 'Should throw - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                        { New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName } | Should -Throw
                    }
                }

                Context 'When a "Project" with supplied "ProjectName" parameter value does not exist' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                        { New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName } | Should -Not -Throw
                    }

                    It 'Should call "Get-AzDevOpsProject" function exactly once - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNameCombined {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                        New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName | Out-Null
                        Should -Invoke Get-AzDevOpsProject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                    }
                }
            }

        }

        Context 'When called with invalid parameters' {
            BeforeAll {
            }

            $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
            $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
            $testCasesValidApiUriPatCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUris, $testCasesValidPats

            $testCasesInvalidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Invalid'
            $testCasesValidApiUriPatInvalidProjectNameCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesInvalidProjectNames

            $testCasesInvalidProjectDescriptions = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Invalid'
            $testCasesValidApiUriPatInvalidProjectDescriptionCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesInvalidProjectDescriptions

            $testCasesInvalidSourceControlTypes = Get-TestCase -ScopeName 'SourceControlType' -TestCaseName 'Invalid'
            $testCasesValidApiUriPatInvalidSourceControlTypeCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesInvalidSourceControlTypes

            Context 'When called with invalid "Pat" parameter' {

                $testCasesEmptyPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Empty'
                $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'

                Context 'When called without "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        { New-AzDevOpsProject -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { New-AzDevOpsProject -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { New-AzDevOpsProject -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

                    }
                }
            }

            Context 'When called with invalid "ApiUri" parameter' {

                $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
                $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

                Context 'When called without "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { New-AzDevOpsProject -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { New-AzDevOpsProject -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { New-AzDevOpsProject -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }


            Context 'When called with invalid "ProjectName" parameter' {

                It 'Should throw - "<ProjectName>"' -TestCases $testCasesValidApiUriPatInvalidProjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    { New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName } | Should -Throw
                }

            }


            Context 'When called with invalid "ProjectDescription" parameter' {

                It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesValidApiUriPatInvalidProjectDescriptionCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName, [string]$ProjectDescription)

                    $ValidProjectName = 'SomeProjectName'
                    { New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ValidProjectName -ProjectDescription $ProjectDescription } | Should -Throw
                }

            }


            Context 'When called with invalid "SourceControlType" parameter' {

                It 'Should throw - "<ProjectDescription>"' -TestCases $testCasesValidApiUriPatInvalidProjectDescriptionCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName, [string]$ProjectDescription, [string]$SourceControlType)

                    $ValidProjectName = 'SomeProjectName'
                    $ValidProjectDescription = 'SomeProjectDescription'
                    { New-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ValidProjectName -ProjectDescription $ValidProjectDescription -SourceControlType $SourceControlType} | Should -Throw
                }

            }
        }

    }

}
