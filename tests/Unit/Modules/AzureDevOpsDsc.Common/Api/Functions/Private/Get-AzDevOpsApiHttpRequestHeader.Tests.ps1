
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Api\Functions\Private\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Api\Function\$script:commandName" -Tag $script:tag {

        $testCasesValidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Valid'
        $testCasesInvalidPats = Get-TestCase -ScopeName 'Pat' -TestCaseName 'Invalid'


        Context 'When input parameters are valid' {

            It 'Should not throw - "<Pat>"' -TestCases $testCasesValidPats {
                param ([System.String]$Pat)

                { Get-AzDevOpsApiHttpRequestHeader -Pat $Pat } | Should -Not -Throw
            }

            It 'Should output a "Hashtable" type - "<Pat>"' -TestCases $testCasesValidPats {
                param ([System.String]$Pat)

                $httpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

                $httpRequestHeader.GetType() | Should -Be $(@{}.GetType())
            }

            It 'Should output a "Hashtable" type containing an "Authorization" key - "<Pat>"' -TestCases $testCasesValidPats {
                param ([System.String]$Pat)

                $httpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

                $httpRequestHeader.ContainsKey('Authorization') | Should -BeTrue
            }

            It 'Should output a "Hashtable" type containing an "Authorization" key that has a value beginning with "Basic " - "<Pat>"' -TestCases $testCasesValidPats {
                param ([System.String]$Pat)

                $httpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

                $httpRequestHeader.Authorization | Should -BeLike "Basic *"
            }

            It 'Should output a "Hashtable" type containing an "Authorization" key that has a value as expected - "<Pat>" ' -TestCases $testCasesValidPats {
                param ([System.String]$Pat)

                $authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
                $httpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

                $httpRequestHeader.Authorization | Should -BeExactly $authorization
            }

            It 'Should output a "Hashtable" type that is successfully validated by "Test-AzDevOpsApiHttpRequestHeader" - "<Pat>"' -TestCases $testCasesValidPats {
                param ([System.String]$Pat)

                $httpRequestHeader = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

                Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $httpRequestHeader -IsValid | Should -BeTrue
            }

        }


        Context "When input parameters are invalid" {

            It 'Should throw - "<Pat>"' -TestCases $testCasesInvalidPats {
                param ([System.String]$Pat)

                { Get-AzDevOpsApiHttpRequestHeader -Pat $Pat } | Should -Throw
            }

        }
    }
}
