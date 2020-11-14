using module ..\..\..\..\source\Classes\DscResourceBase\DscResourceBase.psm1
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


        Context 'When called from instance of a class without any DSC properties with no "Set" support' {

            It 'Should not throw' {

                $dscResourceWithNoSetSupportProperties = [AzDevOpsApiDscResourceBase]::new()

                {$dscResourceWithNoSetSupportProperties.GetDscResourcePropertyNamesWithNoSetSupport()} | Should -Not -Throw
            }

            It 'Should return empty array' {

                $dscResourceWithNoSetSupportProperties = [AzDevOpsApiDscResourceBase]::new()

                $dscResourceWithNoSetSupportProperties.GetDscResourcePropertyNamesWithNoSetSupport().Count | Should -Be 0
            }

        }


        Context 'When called from instance of a class with a DSC property with no "Set" support' {

            It 'Should not throw' {

                $dscResourceWithANoSetSupportProperty = [AzDevOpsProject]@{
                    ProjectName = 'SomeProjectName'
                }

                { $dscResourceWithANoSetSupportProperty.GetDscResourcePropertyNamesWithNoSetSupport() } | Should -Not -Throw
            }

            It 'Should return the correct number of DSC resource property names that do not support "SET"' {

                $dscResourceWithANoSetSupportProperty = [AzDevOpsProject]@{
                    ProjectName = 'SomeProjectName'
                }

                $dscResourceWithANoSetSupportProperty.GetDscResourcePropertyNamesWithNoSetSupport().Count | Should -Be 1
            }

            It 'Should return the correct DSC resource property names that do not support "SET"' {

                $dscResourceWithANoSetSupportProperty = [AzDevOpsProject]@{
                    ProjectName = 'SomeProjectName'
                }

                $dscResourceWithANoSetSupportProperty.GetDscResourcePropertyNamesWithNoSetSupport() | Should -Contain 'SourceControlType'
            }
        }
    }
}
