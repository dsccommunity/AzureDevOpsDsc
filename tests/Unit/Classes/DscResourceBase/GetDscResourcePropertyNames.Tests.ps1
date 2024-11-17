using module ..\..\..\..\output\builtModule\AzureDevOpsDsc\0.2.0\AzureDevOpsDsc.psm1

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


        Context 'When called from instance of the class without any DSC properties' {

            It 'Should not throw' {

                $dscResourceWithNoDscProperties = [DscResourceBase]::new()

                {$dscResourceWithNoDscProperties.GetDscResourcePropertyNames()} | Should -Not -Throw
            }

            It 'Should return empty array' {

                $dscResourceWithNoDscProperties = [DscResourceBase]::new()

                $dscResourceWithNoDscProperties.GetDscResourcePropertyNames().Count | Should -Be 0
            }
        }


        Context 'When called from instance of a class with multiple DSC properties' {

            class DscResourceBase2Properties : DscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [DscProperty()]
                [string]$ADscProperty

                [DscProperty()]
                [string]$AnotherDscProperty
            }

            $dscResourceWith2DscProperties = [DscResourceBase2Properties]@{
                ADscProperty = 'ADscPropertyValue'
                AnotherDscProperty = 'AnotherDscPropertyValue'
            }

            It 'Should not throw' {

                { $dscResourceWith2DscProperties.GetDscResourcePropertyNames() } | Should -Not -Throw
            }

            It 'Should return 2 property names' {

                $dscResourceWith2DscProperties.GetDscResourcePropertyNames().Count | Should -Be 2
            }

            It 'Should return the correct property names' {

                $propertyNames = $dscResourceWith2DscProperties.GetDscResourcePropertyNames()

                $propertyNames | Should -Contain 'ADscProperty'
                $propertyNames | Should -Contain 'AnotherDscProperty'
            }
        }
    }
}
