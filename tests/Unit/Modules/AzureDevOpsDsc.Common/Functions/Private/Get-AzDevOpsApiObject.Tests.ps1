
# Initialize tests for module function
. $PSScriptRoot\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiObject' -Tag 'GetAzDevOpsApiObject' {

        Context 'When called with valid parameters' {
            BeforeAll {

                [string]$nonPresentObjectId = '114bff8d-6169-45cf-b085-fe121267e7aa'

                Mock Invoke-RestMethod -Verifiable {

                    $response = @"
                    {
                        "count": 2,
                        "value": [
                            {
                                "id": "$ObjectId",
                                "name": "Test Project 1",
                                "description": "Test Project Description 1",
                                "url": "https://dev.azure.com/fabrikam/_apis/projects/$ObjectId",
                                "state": "wellFormed"
                            },
                            {
                                "id": "8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                                "name": "Test Project 2",
                                "description": "Test Project Description 2",
                                "url": "https://dev.azure.com/fabrikam/_apis/projects/8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                                "state": "wellFormed"
                            }
                        ]
                    }
"@  | ConvertFrom-Json

                    if (![string]::IsNullOrWhiteSpace($ObjectId))
                    {
                        $response = $response.value |
                            Where-Object { $_.id -eq $ObjectId} |
                            Where-Object { $_.id -ne $nonPresentObjectId}
                    }

                    #if ([string]::IsNullOrWhiteSpace($ObjectId))
                    #{
                    #    $response = $response.Value
                    #}
                    #else {
                    #    $response = $response.Value |
                    #        Where-Object { $_.id -eq $ObjectId }
                    #}

                    return $response
                }
            }

            $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
            $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
            $testCasesValidApiUriPatCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUris, $testCasesValidPats

            $testCasesValidObjectNames = Get-TestCase -ScopeName 'ObjectName' -TestCaseName 'Valid'
            $testCasesValidApiUriPatObjectNameCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesValidObjectNames

            $testCasesValidObjectIds = Get-TestCase -ScopeName 'ObjectId' -TestCaseName 'Valid'
            $testCasesValidApiUriPatObjectNameObjectIdCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatObjectNameCombined, $testCasesValidObjectIds

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

                        $result = Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat -ObjectName $ObjectName -ObjectId $nonPresentObjectId # Non-present "ObjectId"
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

                $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
                $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

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
