
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        # Get default, parameter values
        $defaultApiVersion = Get-AzDevOpsApiVersion -Default

        # Helper function for generating fake resource, JSON response
        Function Get-MockResourceJson
        {
            return '{
                        "count": 3,
                        "value": [
                            {
                                "id": "8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                                "name": "Test Resource 1",
                                "description": "Test Resource Description 1",
                                "url": "https://dev.azure.com/fabrikam/_apis/resources/8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                                "state": "wellFormed"
                            },
                            {
                                "id": "114bff8d-6169-45cf-b085-fe121267e7aa",
                                "name": "Test Resource 2",
                                "description": "Test Resource Description 2",
                                "url": "https://dev.azure.com/fabrikam/_apis/resources/114bff8d-6169-45cf-b085-fe121267e7aa",
                                "state": "wellFormed"
                            },
                            {
                                "id": "a654b805-6be9-477b-a00c-bd76949192c3",
                                "name": "Test Resource 3",
                                "description": "Test Resource Description 3",
                                "url": "https://dev.azure.com/fabrikam/_apis/resources/a654b805-6be9-477b-a00c-bd76949192c3",
                                "state": "wellFormed"
                            }
                        ]
                    }'
        }
        $noOfMockResources = $((Get-MockResourceJson | ConvertFrom-Json).value).Count
        $resourceIdThatExists = '8d4bff8d-6169-45cf-b085-fe12ad67e76b'       # Same as 'Test Resource 1' in 'Get-MockResourceJson', JSON output
        $resourceIdThatDoesNotExist = '7f5a49c8-9424-4ec5-b4b7-1dc76cd05149'
        $resourceIdThatIsInvalid = Get-TestCaseValue -ScopeName 'ResourceId' -TestCaseName 'Invalid'

        # Mock functions called in function
        Mock Invoke-RestMethod {

            #$resourceIdThatExists = '8d4bff8d-6169-45cf-b085-fe12ad67e76b'
            [PSObject]$resources = Get-MockResourceJson | ConvertFrom-Json

            if (![string]::IsNullOrWhiteSpace($ResourceId))
            {
                [PSObject[]]$resources = $resources.value
                [PSObject]$resources = $resources |
                    Where-Object { $_.id -eq $ResourceId}
            }

            return $resources
        }
        # Mock Get-AzDevOpsApiResourceUri # Do not mock
        # Mock Get-AzDevOpsApiHttpRequestHeader # Do not mock

        # Generate valid, test cases
        $testCasesValidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Valid'
        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesValidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Valid'
        $testCasesValidApiUriPatResourceNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesValidApiUris,
            $testCasesValidPats,
            $testCasesValidResourceNames) -Expand
        $testCasesValidApiUriPatResourceNames3 = $testCasesValidApiUriPatResourceNames | Select-Object -First 3

        $validApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Valid' -First 1

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatResourceNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidResourceNames) -Expand
        $testCasesInvalidApiUriPatResourceNames3 = $testCasesInvalidApiUriPatResourceNames | Select-Object -First 3

        $invalidApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Invalid' -First 1


        Context 'When input parameters are valid' {

            Context 'When called with mandatory, "ApiUri", "Pat" and "ResourceName" parameters' {

                It 'Should not throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName } | Should -Not -Throw
                }

                It 'Should return a type of "System.Management.Automation.PsObject[]" - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    [System.Management.Automation.PsObject[]]$resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName

                    $true | Should -Be $true # Note: Will always evaluate true (but strong-typing of $resources variable would fail this test anyway)
                }

                It 'Should return all resources - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    $resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName

                    $resources.Count | Should -Be $noOfMockResources
                }

                It 'Should invoke "Get-AzDevOpsApiResourceUri" only once - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    Mock Get-AzDevOpsApiResourceUri {
                        return "http://someUri.api/"
                    } -Verifiable

                    $resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName

                    Assert-MockCalled 'Get-AzDevOpsApiResourceUri' -Times 1 -Exactly -Scope 'It'
                }

                It 'Should invoke "Get-AzDevOpsApiHttpRequestHeader" only once - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    Mock Get-AzDevOpsApiHttpRequestHeader {
                        Get-TestCaseValue -ScopeName 'HttpRequestHeader' -TestCaseName 'Valid' -First 1
                    } -Verifiable

                    $resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName

                    Assert-MockCalled 'Get-AzDevOpsApiHttpRequestHeader' -Times 1 -Exactly -Scope 'It'
                }

                It 'Should invoke "Invoke-RestMethod" only once - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    Mock Invoke-RestMethod {} -Verifiable

                    $resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName

                    Assert-MockCalled 'Invoke-RestMethod' -Times 1 -Exactly -Scope 'It'
                }

            }


            Context 'When called with mandatory, "ApiUri", "Pat", "ResourceName" and "ResourceId" parameters' {

                Context 'When the "ResourceId" parameter value is invalid' {

                    It 'Should throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatIsInvalid } | Should -Throw
                    }
                }

                Context 'When a resource with the "ResourceId" parameter value does exist' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatExists } | Should -Not -Throw
                    }

                    It 'Should return a type of "System.Management.Automation.PsObject[]" - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        [System.Management.Automation.PsObject[]]$resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatExists

                        $true | Should -Be $true # Note: Will always evaluate true (but strong-typing of $resources variable would fail this test anyway)
                    }

                    It 'Should not return a $null - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        [System.Management.Automation.PsObject]$resource = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatExists

                        $resource | Should -Not -BeNullOrEmpty
                    }

                    It 'Should return a resource with the correct "id"/"ResourceId" - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        [System.Management.Automation.PsObject]$resource = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatExists

                        $resource.id | Should -Be $resourceIdThatExists
                    }
                }


                Context 'When a resource with the "ResourceId" parameter value does not exist' {

                    It 'Should not throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatDoesNotExist } | Should -Not -Throw
                    }

                    It 'Should return a type of "System.Management.Automation.PsObject[]" - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        [System.Management.Automation.PsObject[]]$resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatDoesNotExist

                        $true | Should -Be $true # Note: Will always evaluate true (but strong-typing of $resources variable would fail this test anyway)
                    }

                    It 'Should return no resources - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        [System.Management.Automation.PsObject[]]$resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatDoesNotExist

                        $resources.Count | Should -Be 0
                    }

                    It 'Should return $null - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        $resource = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatDoesNotExist

                        $resource | Should -Be $null
                    }
                }


                Context "When also called with valid 'ApiVersion' parameter value" {

                    It "Should not throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $validApiVersion -Pat $Pat -ResourceName $ResourceName } | Should -Not -Throw
                    }
                }

                Context "When also called with invalid 'ApiVersion' parameter value" {

                    It "Should throw - '<ApiUri>', '<Pat>', '<ResourceId>'" -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        { Get-AzDevOpsApiResource -ApiUri $ApiUri -ApiVersion $invalidApiVersion -Pat $Pat -ResourceName $ResourceName } | Should -Throw
                    }
                }
            }
        }


        Context 'When input parameters are invalid' {

            Context 'When called with mandatory, "ApiUri", "Pat" and "ResourceName" parameters' {

                It 'Should throw - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesinvalidApiUriPatResourceNames {
                    param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                    { Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName } | Should -Throw
                }
            }

        }
    }
}
