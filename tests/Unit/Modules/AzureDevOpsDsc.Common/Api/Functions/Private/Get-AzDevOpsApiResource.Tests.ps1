
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
            param
            (
                [System.String]
                $ResourceId
            )

            return '{
                        "count": 2,
                        "value": [
                            {
                                "id": "$ResourceId",
                                "name": "Test Resource 1",
                                "description": "Test Resource Description 1",
                                "url": "https://dev.azure.com/fabrikam/_apis/resources/$ResourceId",
                                "state": "wellFormed"
                            },
                            {
                                "id": "8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                                "name": "Test Resource 2",
                                "description": "Test Resource Description 2",
                                "url": "https://dev.azure.com/fabrikam/_apis/resources/8d4bff8d-6169-45cf-b085-fe12ad67e76b",
                                "state": "wellFormed"
                            }
                        ]
                    }'
        }
        $noOfMockResources = $(Get-MockResourceJson -ResourceId $([GUID]::NewGuid()) | ConvertFrom-Json).Count
        $resourceIdThatExists = '8d4bff8d-6169-45cf-b085-fe12ad67e76b'
        $resourceIdThatDoesNotExist = '114bff8d-6169-45cf-b085-fe121267e7aa'
        $resourceIdThatIsInvalid = Get-TestCaseValue -ScopeName 'ResourceId' -TestCaseName 'Invalid'

        # Mock functions called in function
        Mock Invoke-RestMethod {

            $resources = Get-MockResourceJson -ResourceId $ResourceId | ConvertFrom-Json
            $nonPresentResourceId = $resourceIdThatDoesNotExist

            if (![string]::IsNullOrWhiteSpace($ResourceId))
            {
                $resources = $resources.value |
                    Where-Object { $_.id -eq $ResourceId} |
                    Where-Object { $_.id -ne $nonPresentResourceId}
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

        $validApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Valid'

        # Generate invalid, test cases
        $testCasesInvalidApiUris = Get-TestCase -ScopeName 'ApiUri' -TestCaseName 'Invalid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'
        $testCasesInvalidResourceNames = Get-TestCase -ScopeName 'ResourceName' -TestCaseName 'Invalid'
        $testCasesInvalidApiUriPatResourceNames = Join-TestCaseArray -TestCaseArray @(
            $testCasesInvalidApiUris,
            $testCasesInvalidPats,
            $testCasesInvalidResourceNames) -Expand
        $testCasesInvalidApiUriPatResourceNames3 = $testCasesInvalidApiUriPatResourceNames | Select-Object -First 3

        $invalidApiVersion = Get-TestCaseValue -ScopeName 'ApiVersion' -TestCaseName 'Invalid'


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

                    It 'Should return only 1 resource - "<ApiUri>", "<Pat>", "<ResourceName>"' -TestCases $testCasesValidApiUriPatResourceNames3 {
                        param ([System.String]$ApiUri, [System.String]$Pat, [System.String]$ResourceName)

                        [System.Management.Automation.PsObject[]]$resources = Get-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat -ResourceName $ResourceName -ResourceId $resourceIdThatExists

                        $resources.Count | Should -Be 1
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
