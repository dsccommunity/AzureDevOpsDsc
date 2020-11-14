using module ..\..\..\..\source\Classes\DscResourceBase\DscResourceBase.psm1
using module ..\..\..\..\source\Classes\AzDevOpsApiDscResourceBase\AzDevOpsApiDscResourceBase.psm1
using module ..\..\..\..\source\DSCClassResources\AzDevOpsProject\AzDevOpsProject.psm1

# Initialize tests for module function
. $PSScriptRoot\..\Classes.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:dscResourceName = Split-Path $PSScriptRoot -Leaf
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Classes\$script:dscResourceName\$script:dscResourceName.psm1"
    $script:tag = @($($script:commandName -replace '-'))


    Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {


        Context 'When called from instance of the class without a DSC Resource key' {

            It 'Should throw' {

                $dscResourceBase = [AzDevOpsApiDscResourceBase]::new()

                {$dscResourceBase.GetDscResourceKey()} | Should -Throw
            }

        }


        Context 'When called from instance of a class with multiple DSC Resource keys' {

            It 'Should throw' {

                class AzDevOpsApiDscResourceBase2DscKeys : AzDevOpsApiDscResourceBase
                {
                    [DscProperty(Key)]
                    [string]$DscKey1

                    [DscProperty(Key)]
                    [string]$DscKey2
                }
                $dscResourceWith2Keys = [AzDevOpsApiDscResourceBase2DscKeys]@{}

                {$dscResourceWith2Keys.GetDscResourceKey()} | Should -Throw
            }

        }


        Context 'When called from instance of class with a DSC key' {

            class AzDevOpsApiDscResourceBase1DscKey : AzDevOpsApiDscResourceBase
            {
                [DscProperty(Key)]
                [string]$DscKey1
            }

            $dscResourceWith1Key = [AzDevOpsApiDscResourceBase1DscKey]@{
                DscKey1='DscKey1Value'
            }

            It 'Should not throw' {

                {$dscResourceWith1Key.GetDscResourceKey()} | Should -Not -Throw
            }

            It 'Should return the value of the DSC Resource key' {

                $dscResourceWith1Key.GetDscResourceKey() | Should -Be 'DscKey1Value'
            }
        }
    }
}
