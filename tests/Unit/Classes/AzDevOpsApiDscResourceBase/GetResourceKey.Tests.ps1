using module ..\..\..\..\output\AzureDevOpsDsc\0.2.0\AzureDevOpsDsc.psm1

# Initialize tests for module function
. $PSScriptRoot\..\Classes.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:dscResourceName = Split-Path $PSScriptRoot -Leaf
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Classes\$script:dscResourceName\$script:dscResourceName.psm1"
    $script:tag = @($($script:commandName -replace '-'))


    Describe "$script:subModuleName\Classes\AzDevOpsApiDscResourceBase\$script:commandName" -Tag $script:tag {


        Context 'When called from instance of the class with the correct/expected, DSC Resource prefix' {

            class AzDevOpsApiDscResourceBaseWithKey : AzDevOpsApiDscResourceBase
            {
                [System.String]$ApiDscResourceBaseId

                [DscProperty(Key)]
                [System.String]$ApiDscResourceBaseKey
            }

            It 'Should not throw' {

                $azDevOpsApiDscResourceBaseWithKey = [AzDevOpsApiDscResourceBaseWithKey]@{
                    ApiDscResourceBaseId  = 'ApiDscResourceBaseIdValue'
                    ApiDscResourceBaseKey = 'ApiDscResourceBaseKeyValue'
                }

                {$azDevOpsApiDscResourceBaseWithKey.GetResourceKey()} | Should -Not -Throw
            }

            It 'Should return the same name as the DSC Resource/class without the expected prefix' {

                $azDevOpsApiDscResourceBaseWithKey = [AzDevOpsApiDscResourceBaseWithKey]@{
                    ApiDscResourceBaseId  = 'ApiDscResourceBaseIdValue'
                    ApiDscResourceBaseKey = 'ApiDscResourceBaseKeyValue'
                }

                $azDevOpsApiDscResourceBaseWithKey.GetResourceKey() | Should -Be 'ApiDscResourceBaseKeyValue'
            }
        }
    }
}
