
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsProject' -Tag 'GetAzDevOpsProject' {

        Context 'When called with valid parameters' {
            BeforeAll {
                Mock -ModuleName $script:subModuleName Get-AzDevOpsApiObject {
                    return @(
                        @{
                            id='8d4bff8d-6169-45cf-b085-fe12ad67e76b';
                            name='Mock Project Name 1'; },
                        @{
                            id='485ab935-7de3-4894-ba6f-ed418d4eda92';
                            name='Mock Project Name 2'; }
                    )
                }
            }


            $testCasesValidApiUris = @(
                @{
                    ApiUri = 'http://someuri.api/_apis/' },
                @{
                    ApiUri = 'https://someuri.api/_apis/' }
            )

            $testCasesValidPats = @(
                @{
                    Pat = '1234567890123456789012345678901234567890123456789012' },
                @{
                    Pat = '0987654321098765432109876543210987654321098765432109' },
                @{
                    Pat = '0913uhuh3wedwndfwsni2242msfwneu254uhufs009oosfmikm34' }
            )

            $testCasesValidApiUriPatCombined = $testCasesValidApiUris | ForEach-Object {

                $apiUri = $_.ApiUri
                $testCasesValidPats | ForEach-Object {

                    $pat = $_.Pat
                    return @{
                        ApiUri = $apiUri
                        Pat = $pat
                    }
                }

            }


            $testCasesValidProjectNames = @( # Note: Same as mock for 'Get-AzDevOpsApiObject'
                @{
                    ProjectName = 'Mock Project Name 1' },
                @{
                    ProjectName = 'Mock Project Name 2' }
            )

            $testCasesValidProjectIds = @( # Note: Same as mock for 'Get-AzDevOpsApiObject'
                @{
                    ProjectId = '8d4bff8d-6169-45cf-b085-fe12ad67e76b' },
                @{
                    ProjectId = '485ab935-7de3-4894-ba6f-ed418d4eda92' }
            )

            $testCasesValidApiUriPatProjectNameCombined = $testCasesValidApiUriPatCombined | ForEach-Object {

                $apiUri = $_.ApiUri
                $pat = $_.Pat
                $testCasesValidProjectNames | ForEach-Object {

                    $projectName = $_.ProjectName
                    return @{
                        ApiUri = $apiUri
                        Pat = $pat
                        ProjectName = $projectName
                    }
                }

            }

            $testCasesValidApiUriPatProjectIdCombined = $testCasesValidApiUriPatCombined | ForEach-Object {

                $apiUri = $_.ApiUri
                $pat = $_.Pat
                $testCasesValidProjectIds | ForEach-Object {

                    $projectId = $_.ProjectId
                    return @{
                        ApiUri = $apiUri
                        Pat = $pat
                        ProjectId = $projectId
                    }
                }

            }


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

                $testCasesEmptyPats = @(
                    @{
                        ApiUri = $null },
                    @{
                        ApiUri = '' }
                )

                $testCasesInvalidPats = @(
                    @{
                        Pat = $null },
                    @{
                        Pat = '' }
                    @{
                        Pat = ' ' },
                    @{
                        Pat = 'a 1' },
                    @{
                        Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm3' },
                    @{
                        Pat = '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm34x' }
                )

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

                $testCasesEmptyApiUris = @(
                    @{
                        ApiUri = $null },
                    @{
                        ApiUri = '' }
                )

                $testCasesInvalidApiUris = @(
                    @{
                        ApiUri = ' ' },
                    @{
                        ApiUri = 'a 1' },

                    # Incorrect prefixes
                    @{
                        ApiUri = 'ftp://someuri.api/_apis/' },
                    @{
                        ApiUri = 'someuri.api/_apis/' },

                    # Missing trailing '/' (after http(s))
                    @{
                        ApiUri = 'http:/someuri.api/_apis/' },
                    @{
                        ApiUri = 'https:/someuri.api/_apis/' },

                    # Missing trailing '/'
                    @{
                        ApiUri = 'http://someuri.api/_apis' },
                    @{
                        ApiUri = 'https://someuri.api/_apis' },

                    # Missing trailing '/_apis/'
                    @{
                        ApiUri = 'http://someuri.api/' },
                    @{
                        ApiUri = 'https://someuri.api/' }
                )

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
