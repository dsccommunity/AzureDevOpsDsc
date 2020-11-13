
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
        Mock Get-AzDevOpsApiResource {} -ModuleName $script:subModuleName

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidApiUriPats = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats) -Expand
        $testCasesValidApiUriPats3 = $testCasesValidApiUriPats | Select-Object -First 3

        $testCasesValidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Valid'
        $testCasesValidApiUriPatProjectIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidProjectIds) -Expand
        $testCasesValidApiUriPatProjectIds3 = $testCasesValidApiUriPatProjectIds | Select-Object -First 3

        $validProjectIdThatExists = '3456bc8e-0c47-440e-bd49-6db608abb461'
        $validProjectIdThatDoesNotExist = '9b03d056-cd1c-4f51-b007-5d1d896e38f0'


        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPats = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats) -Expand
        $testCasesInvalidApiUriPats3 = $testCasesInvalidApiUriPats | Select-Object -First 3

        $testCasesInvalidProjectIds = Get-TestCase -ScopeName 'ProjectId' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatProjectIds = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidProjectIds) -Expand
        $testCasesInvalidApiUriPatProjectIds3 = $testCasesInvalidApiUriPatProjectIds | Select-Object -First 3




        Context 'When input parameters are valid' {


            Context 'When called with mandatory "ApiUri" and "Pat" parameters' {
                Mock Get-AzDevOpsApiResource {}

                It 'Should not throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat } | Should -Not -Throw
                }

                It 'Should invoke "Get-AzDevOpsApiResource" only once - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                    param ([string]$ApiUri, [string]$Pat)

                    Mock Get-AzDevOpsApiResource {} -Verifiable

                    Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat | Out-Null

                    Assert-MockCalled 'Get-AzDevOpsApiResource' -Times 1 -Exactly -Scope 'It'
                }

                Context 'When "Project" resources do exist' {

                    It 'Should return same number of "Project" resources as "Get-AzDevOpsApiResource" does - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                        param ([string]$ApiUri, [string]$Pat)

                        Mock Get-AzDevOpsApiResource {
                            [System.Management.Automation.PSObject[]]$projects = @(
                                $([System.Management.Automation.PSObject]@{
                                    id = '6c5cfb48-ef00-4965-9e8b-8890cea541b0'
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = '3456bc8e-0c47-440e-bd49-6db608abb461' # Same as $validProjectIdThatExists
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

                            if ($script:mockGetAzDevOpsApiResourceInvoked)
                            {
                                $projects = $projects |
                                    Where-Object { $_.id -eq '3456bc8e-0c47-440e-bd49-6db608abb461' } # Same as $validProjectIdThatExists
                            }
                            $script:mockGetAzDevOpsApiResourceInvoked = $true

                            return $projects
                        } -ModuleName $script:subModuleName

                        $projects = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat

                        $projects.Count | Should -Be $($(Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName 'Project').Count)
                    }

                }

                Context 'When "Project" resources do not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                        param ([string]$ApiUri, [string]$Pat)

                        $projects = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat
                        $projects | Should -BeNullOrEmpty
                    }

                    It 'Should return no "Project" resources - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats {
                        param ([string]$ApiUri, [string]$Pat)

                        [System.Management.Automation.PSObject[]]$projects = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat
                        $projects.Count | Should -Be 0
                    }
                }


                Context 'When also called with optional, "ProjectId" parameter' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                        { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId } | Should -Not -Throw
                    }

                    It 'Should invoke "Get-AzDevOpsApiResource" only once - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesValidApiUriPatProjectIds3 {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                        Mock Get-AzDevOpsApiResource {} -Verifiable

                        Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId | Out-Null

                        Assert-MockCalled 'Get-AzDevOpsApiResource' -Times 1 -Exactly -Scope 'It'
                    }


                    Context 'When an "Project" resource exists' {


                        Mock Get-AzDevOpsApiResource {
                            [System.Management.Automation.PSObject[]]$projects = @(
                                $([System.Management.Automation.PSObject]@{
                                    id = '6c5cfb48-ef00-4965-9e8b-8890cea541b0'
                                }),
                                $([System.Management.Automation.PSObject]@{
                                    id = '3456bc8e-0c47-440e-bd49-6db608abb461' # Same as $validProjectIdThatExists
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

                            if ($script:mockGetAzDevOpsApiResourceInvoked)
                            {
                                $projects = $projects |
                                    Where-Object { $_.id -eq '3456bc8e-0c47-440e-bd49-6db608abb461' } # Same as $validProjectIdThatExists
                            }
                            $script:mockGetAzDevOpsApiResourceInvoked = $true

                            return $projects
                        } -ModuleName $script:subModuleName

                        It 'Should return exactly 1 "Project" resource - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            $script:mockGetAzDevOpsApiResourceInvoked = $false # For mock of 'Get-AzDevOpsApiResource'

                            [System.Management.Automation.PSObject[]]$projects = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $validProjectIdThatExists
                            $projects.Count | Should -Be 1
                        }

                        It 'Should return exactly 1 "Project" resource with identical "id" - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            $script:mockGetAzDevOpsApiResourceInvoked = $false # For mock of 'Get-AzDevOpsApiResource'

                            [System.Management.Automation.PSObject]$project = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $validProjectIdThatExists

                            $project.id | Should -Be $validProjectIdThatExists
                        }

                    }


                    Context 'When an "Project" resource does not exist' {

                        It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            $projects = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $validProjectIdThatDoesNotExist
                            $projects | Should -BeNullOrEmpty
                        }

                        It 'Should return no "Project" resources - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPats3 {
                            param ([string]$ApiUri, [string]$Pat)

                            [System.Management.Automation.PSObject[]]$projects = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $validProjectIdThatDoesNotExist
                            $projects.Count | Should -Be 0
                        }
                    }
                }
            }
        }


        Context 'When input parameters are invalid' {


            Context 'When called with invalid, mandatory "ApiUri" and "Pat" parameters' {

                It 'Should throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesInvalidApiUriPats {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat } | Should -Throw
                }


                Context 'When also called with invalid, optional, "ProjectId" parameter' {

                    It 'Should throw - "<ApiUri>", "<Pat>", "<ProjectId>"' -TestCases $testCasesInvalidApiUriPatProjectIds {
                        param ([string]$ApiUri, [string]$Pat, [string]$ProjectId)

                        { Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId } | Should -Throw
                    }
                }

            }

        }
    }
}
