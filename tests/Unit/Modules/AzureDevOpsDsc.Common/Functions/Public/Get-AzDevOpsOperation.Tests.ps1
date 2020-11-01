
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsOperation' -Tag 'GetAzDevOpsOperation' {

        Context 'When called with valid parameters' {
            BeforeAll {
                Mock -ModuleName $script:subModuleName Get-AzDevOpsApiObject {
                    return @(
                        @{
                            id='8d4bff8d-6169-45cf-b085-fe12ad67e76b';},
                        @{
                            id='485ab935-7de3-4894-ba6f-ed418d4eda92';}
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

            $testCasesValidOperationIds = @( # Note: Same as mock for 'Get-AzDevOpsApiObject'
                @{
                    OperationId = '8d4bff8d-6169-45cf-b085-fe12ad67e76b' },
                @{
                    OperationId = '485ab935-7de3-4894-ba6f-ed418d4eda92' }
            )

            $testCasesValidApiUriPatOperationIdCombined = $testCasesValidApiUriPatCombined | ForEach-Object {

                $apiUri = $_.ApiUri
                $pat = $_.Pat
                $testCasesValidOperationIds | ForEach-Object {

                    $OperationId = $_.OperationId
                    return @{
                        ApiUri = $apiUri
                        Pat = $pat
                        OperationId = $OperationId
                    }
                }

            }


            Context 'When called with no "OperationId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    $result = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                    param ([string]$ApiUri, [string]$Pat)

                    Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat | Out-Null
                    Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

            }


            Context 'When called with a "OperationId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    $result = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId
                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>", "<OperationId>"' -TestCases $testCasesValidApiUriPatOperationIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$OperationId)

                    Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId $OperationId | Out-Null
                    Should -Invoke Get-AzDevOpsApiObject -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

                Context 'When a "Operation" with supplied "OperationId" parameter value does not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>"' -TestCases $testCasesValidApiUriPatCombined {
                        param ([string]$ApiUri, [string]$Pat)

                        $result = Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $Pat -OperationId '114bff8d-6169-45cf-b085-fe121267e7aa' # Non-present "OperationId"
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

                        { Get-AzDevOpsOperation -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { Get-AzDevOpsOperation -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { Get-AzDevOpsOperation -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

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

                        { Get-AzDevOpsOperation -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { Get-AzDevOpsOperation -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }
        }

    }

}
