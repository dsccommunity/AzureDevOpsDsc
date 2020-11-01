
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiObject' -Tag 'GetAzDevOpsApiObject' {

        Context 'When called with valid parameters' {
            BeforeAll {
                Mock Invoke-RestMethod {
                    $response = @'
                    {
                        "count": 2,
                        "value": [
                          {
                            "id": "8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                            "name": "Test Project 1",
                            "description": "Test Project Description 1",
                            "url": "https://dev.azure.com/fabrikam/_apis/projects/8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                            "state": "wellFormed"
                          },
                          {
                            "id": "485ab935-7de3-4894-ba6f-ed418d4eda92",
                            "name": "Test Project 2",
                            "description": "Test Project Description 2",
                            "url": "https://dev.azure.com/fabrikam/_apis/projects/485ab935-7de3-4894-ba6f-ed418d4eda92",
                            "state": "wellFormed"
                          }
                        ]
                      }
'@ | ConvertFrom-Json

                    if ([string]::IsNullOrWhiteSpace($ObjectId))
                    {
                        $response = $response.Value
                    }
                    else {
                        $response = $response.Value |
                            Where-Object { $_.id -eq $ObjectId }
                    }

                    return $response
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


            $testCasesValidObjectNames = @(
                @{
                    ObjectName = 'Operation' },
                @{
                    ObjectName = 'Project' }
            )

            $testCasesValidObjectIds = @( # Note: Same as mock for 'Invoke-RestMethod'
                @{
                    ObjectId = '8d4bff8d-6169-45cf-b085-fe12ad67e76b' },
                @{
                    ObjectId = '485ab935-7de3-4894-ba6f-ed418d4eda92' }
            )

            $testCasesValidApiUriPatObjectNameCombined = $testCasesValidApiUriPatCombined | ForEach-Object {

                $apiUri = $_.ApiUri
                $pat = $_.Pat
                $testCasesValidObjectNames | ForEach-Object {

                    $objectName = $_.ObjectName
                    return @{
                        ApiUri = $apiUri
                        Pat = $pat
                        ObjectName = $objectName
                    }
                }

            }

            $testCasesValidApiUriPatObjectNameObjectIdCombined = $testCasesValidApiUriPatObjectNameCombined | ForEach-Object {

                $apiUri = $_.ApiUri
                $pat = $_.Pat
                $objectName = $_.ObjectName
                $testCasesValidObjectIds | ForEach-Object {

                    $objectId = $_.ObjectId
                    return @{
                        ApiUri = $apiUri
                        Pat = $pat
                        ObjectName = $objectName
                        ObjectId = $objectId
                    }
                }

            }


            Context 'When called with no "ObjectId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ObjectName>"' -TestCases $testCasesValidApiUriPatObjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ObjectName)

                    { Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ObjectName>"' -TestCases $testCasesValidApiUriPatObjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ObjectName)

                    $result = Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName
                    #Write-Warning "x"
                    #Write-Warning "$ApiUri"
                    #Write-Warning "$Pat"
                    #Write-Warning "$ObjectName"
                    #Write-Warning "$result"
                    #Write-Warning "yy"

                    #$result

                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>", "<ObjectName>"' -TestCases $testCasesValidApiUriPatObjectNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ObjectName)

                    Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName | Out-Null
                    Should -Invoke Invoke-RestMethod -Times 1 -Exactly -Scope It
                }

            }


            Context 'When called with an "ObjectId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ObjectName>", "<ObjectId>"' -TestCases $testCasesValidApiUriPatObjectNameObjectIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ObjectName, [string]$ObjectId)

                    { Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName -ObjectId $ObjectId } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ObjectName>", "<ObjectId>"' -TestCases $testCasesValidApiUriPatObjectNameObjectIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ObjectName, [string]$ObjectId)

                    $result = Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName -ObjectId $ObjectId

                    $result.GetType() | Should -Be $(New-Object -TypeName PSCustomObject).GetType()
                }

                It 'Should call "Get-AzDevOpsApiObject" function only once - "<ApiUri>", "<Pat>", "<ObjectName>", "<ObjectId>"' -TestCases $testCasesValidApiUriPatObjectNameObjectIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ObjectName, [string]$ObjectId)

                    Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName -ObjectId $ObjectId | Out-Null
                    Should -Invoke Invoke-RestMethod -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

                Context 'When a "Object" with supplied "ObjectId" parameter value does not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>", "<ObjectName>"' -TestCases $testCasesValidApiUriPatObjectNameCombined {
                        param ([string]$ApiUri, [string]$Pat, [string]$ObjectName)

                        $result = Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName -ObjectId '114bff8d-6169-45cf-b085-fe121267e7aa' # Non-present "ObjectId"
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

                        { Get-AzDevOpsApiObject -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { Get-AzDevOpsApiObject -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { Get-AzDevOpsApiObject -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

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

                        { Get-AzDevOpsApiObject -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }
        }

    }

}
