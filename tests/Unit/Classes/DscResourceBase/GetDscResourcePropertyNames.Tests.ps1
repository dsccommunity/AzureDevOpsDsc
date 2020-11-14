using module ..\..\..\..\source\Classes\DscResourceBase\DscResourceBase.psm1


InModuleScope 'AzureDevOpsDsc' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:dscResourceName = Split-Path $PSScriptRoot -Leaf
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Classes\$script:dscResourceName\$script:dscResourceName.psm1"
    $script:tag = @($($script:commandName -replace '-'))

    Import-Module $script:commandScriptPath -Force

    Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {


        Context 'When called from instance of the class without any DSC properties' {

            It 'Should not throw' {

                $dscResourceWithNoDscProperties = [AzDevOpsApiDscResourceBase]::new()

                {$dscResourceWithNoDscProperties.GetDscResourcePropertyNames()} | Should -Not -Throw
            }

            It 'Should return empty array' {

                $dscResourceWithNoDscProperties = [AzDevOpsApiDscResourceBase]::new()

                $dscResourceWithNoDscProperties.GetDscResourcePropertyNames().Count | Should -Be 0
            }

        }

        Context 'When called from instance of a class with multiple DSC Resource keys' {

            It 'Should not throw' {

                class AzDevOpsApiDscResourceBase2 : AzDevOpsApiDscResourceBase
                {
                    [DscProperty()]
                    [string]$ADscProperty

                    [DscProperty()]
                    [string]$AnotherDscProperty
                }

                $dscResourceWith2DscProperties = [AzDevOpsApiDscResourceBase2]@{
                    ADscProperty = 'ADscPropertyValue'
                    AnotherDscProperty = 'AnotherDscPropertyValue'
                }

                { $dscResourceWith2DscProperties.GetDscResourcePropertyNames() } | Should -Not -Throw
            }

            It 'Should not throw' {

                class AzDevOpsApiDscResourceBase2 : AzDevOpsApiDscResourceBase
                {
                    [DscProperty()]
                    [string]$ADscProperty

                    [DscProperty()]
                    [string]$AnotherDscProperty
                }

                $dscResourceWith2DscProperties = [AzDevOpsApiDscResourceBase2]@{
                    ADscProperty = 'ADscPropertyValue'
                    AnotherDscProperty = 'AnotherDscPropertyValue'
                }

                $dscResourceWith2DscProperties.GetDscResourcePropertyNames().Count | Should -Be 2
            }

        }
    }
}
