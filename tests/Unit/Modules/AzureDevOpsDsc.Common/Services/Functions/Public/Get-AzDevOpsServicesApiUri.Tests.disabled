
# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Modules\$($script:subModuleName)\Services\Functions\Public\$($script:commandName).ps1"
    $script:tag = @($($script:commandName -replace '-'))

    . $script:commandScriptPath


    Describe "$script:subModuleName\Services\Functions\Public\$script:commandName" -Tag $script:tag {

        $testCasesValidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Valid'
        $testCasesInvalidOrganizationNames = Get-TestCase -ScopeName 'OrganizationName' -TestCaseName 'Invalid'


        Context 'When called with valid parameters' {

            It 'Should not throw - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                param ([string]$OrganizationName)

                { Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName } | Should -Not -Throw
            }

            It 'Should return correct, URI - "<OrganizationName>"' -TestCases $testCasesValidOrganizationNames {
                param ([string]$OrganizationName)

                Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName |
                    Should -BeExactly "https://dev.azure.com/$($OrganizationName.ToLower())/_apis/"
            }


            Context 'When called with uppercase "OrganizationName" parameter value  - "<OrganizationName>"' {

                It 'Should return URI in lowercase' -TestCases $testCasesValidOrganizationNames {
                    param ([string]$OrganizationName)

                    Get-AzDevOpsServicesApiUri -OrganizationName $($OrganizationName.ToUpper()) |
                        Should -BeExactly $($(Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName).ToLower())
                }
            }
        }


        Context 'When called with invalid parameters' {

            It "Should throw - '<OrganizationName>'" -TestCases $testCasesInvalidOrganizationNames {
                param ([string]$OrganizationName)

                { Get-AzDevOpsServicesApiUri -OrganizationName $OrganizationName } | Should -Throw

            }

        }

    }
}
