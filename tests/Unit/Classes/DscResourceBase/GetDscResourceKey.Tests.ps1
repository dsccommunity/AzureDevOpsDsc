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

    Import-Module $script:commandScriptPath -Force

    Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {


        Context 'When called from instance of the class without a DSC Resource key' {

            It 'Should throw' {

                $dscResourceBase = [AzDevOpsApiDscResourceBase]::new()
                {$dscResourceBase.GetDscResourceKey()} | Should -Throw
            }

        }


        Context 'When called from instance of a class with multiple DSC Resource keys' {

            It 'Should throw' {

                class AzDevOpsProject2 : AzDevOpsProject
                {
                    [DscProperty(Key)]
                    [string]$ProjectName2
                }

                $dscResourceWith2Keys = [AzDevOpsProject2]@{
                    ProjectName = 'SomeProjectName2'
                }

                {$dscResourceWith2Keys.GetDscResourceKey()} | Should -Throw
            }

        }


        Context 'When called from instance of class with a DSC key' {

            $dscResourceWithKey = [AzDevOpsProject]@{
                ProjectName = 'SomeProjectName'
            }

            It 'Should not throw' {

                {$dscResourceWithKey.GetDscResourceKey()} | Should -Not -Throw
            }

            It 'Should return the value of the DSC Resource key' {

                $dscResourceWithKey.GetDscResourceKey() | Should -Be 'SomeProjectName'
            }
        }

    }
}
