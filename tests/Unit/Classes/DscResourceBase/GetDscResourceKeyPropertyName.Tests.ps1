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


    Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {


        Context 'When called from instance of the class without a DSC Resource key' {

            It 'Should throw' {

                $dscResourceWithNoDscKey = [DscResourceBase]::new()

                {$dscResourceWithNoDscKey.GetDscResourceKeyPropertyName()} | Should -Throw
            }
        }


        Context 'When called from instance of a class with multiple DSC Resource keys' {

            It 'Should throw' {

                class DscResourceBase2Keys : DscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
                {
                    [DscProperty(Key)]
                    [string]$DscKey1

                    [DscProperty(Key)]
                    [string]$DscKey2
                }

                $dscResourceWith2Keys = [DscResourceBase2Keys]@{
                    DscKey1 = 'DscKey1Value'
                    DscKey2 = 'DscKey2Value'
                }

                {$dscResourceWith2Keys.GetDscResourceKeyPropertyName()} | Should -Throw
            }
        }


        Context 'When called from instance of class with a DSC key' {

            class DscResourceBase1Key : DscResourceBase
            {
                [DscProperty(Key)]
                [string]$DscKey1
            }

            $dscResourceWith1Key = [DscResourceBase1Key]@{
                DscKey1 = 'DscKey1Value'
            }

            It 'Should not throw' {

                {$dscResourceWith1Key.GetDscResourceKeyPropertyName()} | Should -Not -Throw
            }

            It 'Should return the value of the DSC Resource key' {

                $dscResourceWith1Key.GetDscResourceKeyPropertyName() | Should -Be 'DscKey1'
            }
        }
    }
}
