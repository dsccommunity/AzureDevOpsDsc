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


    Describe "$script:subModuleName\Classes\AzDevOpsApiDscResourceBase\$script:commandName" -Tag $script:tag {


        $DscResourcePrefix = 'AzDevOps'

        Context 'When called from instance of the class without the correct/expected, DSC Resource prefix' {

            class DscResourceWithWrongPrefix : AzDevOpsApiDscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [DscProperty(Key)]
                [string]$DscKey

                [string]GetResourceName()
                {
                    return 'DscResourceWithWrongPrefix'
                }
            }
            $dscResourceWithWrongPrefix = [DscResourceWithWrongPrefix]@{}

            It 'Should not throw' {

                $dscResourceWithWrongPrefix = [DscResourceWithWrongPrefix]::new()

                {$dscResourceWithWrongPrefix.GetResourceName()} | Should -Not -Throw
            }

            It 'Should return the same name as the DSC Resource/class' {

                $dscResourceWithWrongPrefix = [DscResourceWithWrongPrefix]::new()

                $dscResourceWithWrongPrefix.GetResourceName() | Should -Be 'DscResourceWithWrongPrefix'
            }
        }


        Context 'When called from instance of the class with the correct/expected, DSC Resource prefix' {

            class AzDevOpsApiDscResourceBaseExample : AzDevOpsApiDscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [DscProperty(Key)]
                [string]$DscKey

                [string]GetResourceName()
                {
                    return 'ApiDscResourceBaseExample'
                }
            }

            It 'Should not throw' {

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

                {$azDevOpsApiDscResourceBase.GetResourceName()} | Should -Not -Throw
            }

            It 'Should return the same name as the DSC Resource/class without the expected prefix' {

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

                $azDevOpsApiDscResourceBase.GetResourceName() | Should -Be 'AzDevOpsApiDscResourceBaseExample'.Replace('AzDevOps','')
            }
        }
    }
}
