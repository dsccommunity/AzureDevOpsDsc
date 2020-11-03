
# Initialize tests for module function
. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1


InModuleScope $script:subModuleName {

    Describe 'AzureDevOpsDsc.Common\Get-AzDevOpsApiResource' -Tag 'GetAzDevOpsApiResource' {

        Context 'When called with valid parameters' {
            BeforeAll {

                [string]$nonPresentResourceId = '114bff8d-6169-45cf-b085-fe121267e7aa'

                Mock Invoke-RestMethod -Verifiable {

                    $response = @"
                    {
                        "count": 2,
                        "value": [
                            {
                                "id": "$ResourceId",
                                "name": "Test Project 1",
                                "description": "Test Project Description 1",
                                "url": "https://dev.azure.com/fabrikam/_apis/projects/$ResourceId",
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

                    if (![string]::IsNullOrWhiteSpace($ResourceId))
                    {
                        $response = $response.value |
                            Where-Object { $_.id -eq $ResourceId} |
                            Where-Object { $_.id -ne $nonPresentResourceId}
                    }

                    #if ([string]::IsNullOrWhiteSpace($ResourceId))
                    #{
                    #    $response = $response.Value
                    #}
                    #else {
                    #    $response = $response.Value |
                    #        Where-Object { $_.id -eq $ResourceId }
                    #}

                    return $response
                }
            }

            $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
            $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
            $testCasesValidApiUriPatCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUris, $testCasesValidPats

            $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
            $testCasesValidApiUriPatResourceNameCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatCombined, $testCasesValidResourceNames

            $testCasesValidResourceIds = Get-TestCase -ScopeName 'ResourceId' -TestCaseName 'Valid'
            $testCasesValidApiUriPatResourceNameResourceIdCombined = Join-TestCaseArray -Expand -TestCases $testCasesValidApiUriPatResourceNameCombined, $testCasesValidResourceIds

            Context 'When called with no "ResourceId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ResourceName)

                    { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ResourceName)

                    $result = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName
                    #Write-Warning "x"
                    #Write-Warning "$ApiUri"
                    #Write-Warning "$Pat"
                    #Write-Warning "$ResourceName"
                    #Write-Warning "$result"
                    #Write-Warning "yy"

                    #$result

                    $result.GetType() | Should -BeIn @(@(@{},@{}).GetType(),@{}.GetType())
                }

                It 'Should call "Get-AzDevOpsApiResource" function only once - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNameCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ResourceName)

                    Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName | Out-Null
                    Should -Invoke Invoke-RestMethod -Times 1 -Exactly -Scope It
                }

            }


            Context 'When called with an "ResourceId" parameter' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ResourceName>", "<ResourceId>"' -TestCases $testCasesValidApiUriPatResourceNameResourceIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ResourceName, [string]$ResourceId)

                    { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $ResourceId } | Should -Not -Throw
                }

                It 'Should return "object[]" or "hashtable" - "<ApiUri>", "<Pat>", "<ResourceName>", "<ResourceId>"' -TestCases $testCasesValidApiUriPatResourceNameResourceIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ResourceName, [string]$ResourceId)

                    $result = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $ResourceId

                    $result.GetType() | Should -Be $(New-Object -TypeName PSCustomObject).GetType()
                }

                It 'Should call "Get-AzDevOpsApiResource" function only once - "<ApiUri>", "<Pat>", "<ResourceName>", "<ResourceId>"' -TestCases $testCasesValidApiUriPatResourceNameResourceIdCombined {
                    param ([string]$ApiUri, [string]$Pat, [string]$ResourceName, [string]$ResourceId)

                    Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $ResourceId | Out-Null
                    Should -Invoke Invoke-RestMethod -ModuleName $script:subModuleName -Times 1 -Exactly -Scope It
                }

                Context 'When a "Resource" with supplied "ResourceId" parameter value does not exist' {

                    It 'Should return $null - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNameCombined {
                        param ([string]$ApiUri, [string]$Pat, [string]$ResourceName)

                        $result = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $nonPresentResourceId # Non-present "ResourceId"
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

                        { Get-AzDevOpsApiResource -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with valid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $validApiUri = 'https://someuri.api/_apis/'
                        { Get-AzDevOpsApiResource -ApiUri $validApiUri -Pat $Pat } | Should -Throw

                    }
                }

                Context 'When called with invalid "ApiUri" parameter' {
                    It "Should throw - '<Pat>'" -TestCases $testCasesInvalidPats {
                        param ([string]$Pat)

                        $invalidApiUri = 'someInvalidApiUrl'
                        { Get-AzDevOpsApiResource -ApiUri $invalidApiUri -Pat $Pat } | Should -Throw

                    }
                }
            }

            Context 'When called with invalid "ApiUri" parameter' {

                $testCasesEmptyApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Empty'
                $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'

                Context 'When called without "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        { Get-AzDevOpsApiResource -ApiUri $ApiUri } | Should -Throw

                    }
                }

                Context 'When called with valid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $validPat = '1234567890123456789012345678901234567890123456789012'
                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $validPat } | Should -Throw

                    }
                }

                Context 'When called with invalid "Pat" parameter' {
                    It "Should throw - '<ApiUri>'" -TestCases $testCasesInvalidApiUris {
                        param ([string]$ApiUri)

                        $invalidPat = '123456789012'
                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $invalidPat } | Should -Throw

                    }
                }
            }
        }

    }

}
