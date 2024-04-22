
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Resources\Functions\Public\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Resources\Functions\Public\$script:commandName" -Tag $script:tag {


        # Mock functions called in function
        Mock Get-AzDevOpsProject {}

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
        $testCasesValidApiUriPatProjectIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidProjectIds) -Expand
        $testCasesValidApiUriPatProjectIds3 = $testCasesValidApiUriPatProjectIds | Select-Object -First 3

        $testCasesValidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Valid'
        $testCasesValidApiUriPatProjectNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidProjectNames) -Expand
        $testCasesValidApiUriPatProjectNames3 = $testCasesValidApiUriPatProjectNames | Select-Object -First 3

        $testCasesValidApiUriPatProjectIdProjectNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidProjectIds,
            $testCasesValidProjectNames) -Expand
        $testCasesValidApiUriPatProjectIdProjectNames3 = $testCasesValidApiUriPatProjectIdProjectNames | Select-Object -First 3

        $validApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Valid' -First 1

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatProjectIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidProjectIds) -Expand
        $testCasesInvalidApiUriPatProjectIds3 = $testCasesInvalidApiUriPatProjectIds | Select-Object -First 3

        $testCasesInvalidProjectNames = Get-TestCase -ScopeName 'ProjectName' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatProjectNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidProjectNames) -Expand
        $testCasesInvalidApiUriPatProjectNames3 = $testCasesInvalidApiUriPatProjectNames | Select-Object -First 3

        $testCasesInvalidApiUriPatProjectIdProjectNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidProjectIds,
            $testCasesInvalidProjectNames) -Expand
        $testCasesInvalidApiUriPatProjectIdProjectNames3 = $testCasesInvalidApiUriPatProjectIdProjectNames | Select-Object -First 3

        $invalidApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Invalid' -First 1


        Context 'When input parameters are valid' {


            Context 'When called with mandatory "ApiUri", "Pat" and "ProjectId" parameters' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIds {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                    { Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId } | Should -Not -Throw
                }

                It 'Should invoke "Get-AzDevOpsProject" only once - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIds3 {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                    Mock Get-AzDevOpsProject {} -Verifiable

                    Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId | Out-Null

                    Assert-MockCalled 'Get-AzDevOpsProject' -Times 1 -Exactly -Scope 'It'
                }


                Context 'When "Get-AzDevOpsProject" returns a present record (with an "id" property)' {

                    It 'Should return $true - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                        Mock Get-AzDevOpsProject {
                            return $([PSObject]@{
                                id = "62d7a991-b78e-4386-b14e-e4eb2a805947"
                            })
                        }

                        Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId | Should -BeTrue
                    }
                }


                Context 'When "Get-AzDevOpsProject" does not return a record (with no "id" property)' {

                    It 'Should return $false - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                        Mock Get-AzDevOpsProject {}

                        Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId | Should -BeFalse
                    }
                }
            }


            Context 'When called with mandatory "ApiUri", "Pat" and "ProjectName" parameters' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNames {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    { Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName } | Should -Not -Throw
                }

                It 'Should invoke "Get-AzDevOpsProject" only once - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNames3 {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                    Mock Get-AzDevOpsProject {} -Verifiable

                    Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName

                    Assert-MockCalled 'Get-AzDevOpsProject' -Times 1 -Exactly -Scope 'It'
                }


                Context 'When "Get-AzDevOpsProject" returns a present record (with an "id" property)' {

                    It 'Should return $true - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNames {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                        Mock Get-AzDevOpsProject {
                            return $([PSObject]@{
                                id = "62d7a991-b78e-4386-b14e-e4eb2a805947"
                            })
                        }

                        Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName | Should -BeTrue
                    }
                }


                Context 'When "Get-AzDevOpsProject" does not return a record (with no "id" property)' {

                    It 'Should return $false - "<ApiUri>", "<Pat>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectNames {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectName)

                        Mock Get-AzDevOpsProject {}

                        Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName | Should -BeFalse
                    }
                }

            }


            Context 'When called with mandatory "ApiUri", "Pat", "ProjectId" and "ProjectName" parameters' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectId>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectIdProjectNames {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId, [string]$ProjectName)

                    { Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName } | Should -Not -Throw
                }

                It 'Should invoke "Get-AzDevOpsProject" only once - "<ApiUri>", "<Pat>", "<ProjectId>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectIdProjectNames3 {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId, [string]$ProjectName)

                    Mock Get-AzDevOpsProject {} -Verifiable

                    Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName

                    Assert-MockCalled 'Get-AzDevOpsProject' -Times 1 -Exactly -Scope 'It'
                }


                Context 'When "Get-AzDevOpsProject" returns a present record (with an "id" property)' {

                    It 'Should return $true - "<ApiUri>", "<Pat>", "<ProjectId>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectIdProjectNames {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId, [string]$ProjectName)

                        Mock Get-AzDevOpsProject {
                            return $([PSObject]@{
                                id = "62d7a991-b78e-4386-b14e-e4eb2a805947"
                            })
                        }

                        Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName | Should -BeTrue
                    }
                }


                Context 'When "Get-AzDevOpsProject" does not return a record (with no "id" property)' {

                    It 'Should return $false - "<ApiUri>", "<Pat>", "<ProjectId>", "<ProjectName>"' -TestCases $testCasesValidApiUriPatProjectIdProjectNames {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId, [string]$ProjectName)

                        Mock Get-AzDevOpsProject {}

                        Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName | Should -BeFalse
                    }
                }

            }
        }


        Context 'When input parameters are invalid' {


            Context 'When called with mandatory "ApiUri", "Pat", "ProjectId" and "ProjectName" parameters' {

                It 'Should throw - "<ApiUri>", "<Pat>", "<ProjectId>", "<ProjectName>"' -TestCases $testCasesInvalidApiUriPatProjectIdProjectNames {
                    param ([string]$ApiUri, [string]$Pat, [string]$ProjectId, [string]$ProjectName)

                    { Test-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName } | Should -Throw
                }

            }
        }
    }
}
