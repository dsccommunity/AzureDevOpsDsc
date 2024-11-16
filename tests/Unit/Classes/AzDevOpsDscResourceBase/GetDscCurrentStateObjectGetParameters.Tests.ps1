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


    Describe "$script:subModuleName\Classes\AzDevOpsDscResourceBase\$script:commandName" -Tag $script:tag {


        Context 'When a "ResourceId" property value is present'{

            class AzDevOpsDscResourceBaseExample : AzDevOpsDscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [string]$ApiUri = 'https://some.api/_apis/'
                [string]$Pat = '1234567890123456789012345678901234567890123456789012'


                [string]GetResourceName()
                {
                    return 'AzDevOpsDscResourceBaseExample'
                }


                [DscProperty(Key)]
                [string]$AzDevOpsDscResourceBaseExampleKey = 'AzDevOpsDscResourceBaseExampleKeyValue'

                [string]GetResourceKeyPropertyName()
                {
                    return 'AzDevOpsDscResourceBaseExampleKey'
                }

                [string]GetResourceKey()
                {
                    return 'AzDevOpsDscResourceBaseExampleKeyValue'
                }


                [DscProperty()]
                [string]$AzDevOpsDscResourceBaseExampleId = '31e71307-09b3-4d8a-b65c-5c714f64205f' # Random GUID

                [string]GetResourceIdPropertyName()
                {
                    return 'AzDevOpsDscResourceBaseExampleId'
                }

                [string]GetResourceId()
                {
                    return '31e71307-09b3-4d8a-b65c-5c714f64205f' # Random GUID
                }


            }

            It 'Should not throw' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

               {$azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()} | Should -Not -Throw
            }

            It 'Should return an object with "ApiUri" property value equal to object instance "ApiUri" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters().ApiUri | Should -Be $azDevOpsDscResourceBaseExample.ApiUri
            }

            It 'Should return an object with "Pat" property value equal to object instance "Pat" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters().Pat | Should -Be $azDevOpsDscResourceBaseExample.Pat
            }

            It 'Should return an object with "ResourceKey" property value equal to object instance "ResourceKey" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()."$($azDevOpsDscResourceBaseExample.GetResourceKeyPropertyName())" |
                    Should -Be $azDevOpsDscResourceBaseExample."$($azDevOpsDscResourceBaseExample.GetResourceKeyPropertyName())"
            }

            It 'Should return an object with "ResourceId" property value equal to object instance "ResourceId" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()."$($azDevOpsDscResourceBaseExample.GetResourceIdPropertyName())" |
                    Should -Be $azDevOpsDscResourceBaseExample."$($azDevOpsDscResourceBaseExample.GetResourceIdPropertyName())"
            }

            It 'Should return an object with "ResourceId" property value that is not $null' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()."$($azDevOpsDscResourceBaseExample.GetResourceIdPropertyName())" |
                    Should -Not -BeNullOrEmpty
            }

        }


        Context 'When a "ResourceId" property value is not present'{

            class AzDevOpsDscResourceBaseExample : AzDevOpsDscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [string]$ApiUri = 'https://some.api/_apis/'
                [string]$Pat = '1234567890123456789012345678901234567890123456789012'


                [string]GetResourceName()
                {
                    return 'AzDevOpsDscResourceBaseExample'
                }


                [DscProperty(Key)]
                [string]$AzDevOpsDscResourceBaseExampleKey = 'AzDevOpsDscResourceBaseExampleKeyValue'

                [string]GetResourceKeyPropertyName()
                {
                    return 'AzDevOpsDscResourceBaseExampleKey'
                }

                [string]GetResourceKey()
                {
                    return 'AzDevOpsDscResourceBaseExampleKeyValue'
                }


                [DscProperty()]
                [string]$AzDevOpsDscResourceBaseExampleId

                [string]GetResourceIdPropertyName()
                {
                    return 'AzDevOpsDscResourceBaseExampleId'
                }

                [string]GetResourceId()
                {
                    return $null
                }


            }

            It 'Should not throw' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

               {$azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()} | Should -Not -Throw
            }

            It 'Should return an object with "ApiUri" property value equal to object instance "ApiUri" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters().ApiUri | Should -Be $azDevOpsDscResourceBaseExample.ApiUri
            }

            It 'Should return an object with "Pat" property value equal to object instance "Pat" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters().Pat | Should -Be $azDevOpsDscResourceBaseExample.Pat
            }

            It 'Should return an object with "ResourceKey" property value equal to object instance "ResourceKey" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()."$($azDevOpsDscResourceBaseExample.GetResourceKeyPropertyName())" |
                    Should -Be $azDevOpsDscResourceBaseExample."$($azDevOpsDscResourceBaseExample.GetResourceKeyPropertyName())"
            }

            It 'Should return an object with "ResourceId" property value equal to object instance "ResourceId" value' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()."$($azDevOpsDscResourceBaseExample.GetResourceIdPropertyName())" |
                    Should -Be $azDevOpsDscResourceBaseExample."$($azDevOpsDscResourceBaseExample.GetResourceIdPropertyName())"
            }

            It 'Should return an object with "ResourceId" property value that is $null' {
                $azDevOpsDscResourceBaseExample = [AzDevOpsDscResourceBaseExample]::new()

                $azDevOpsDscResourceBaseExample.GetDscCurrentStateObjectGetParameters()."$($azDevOpsDscResourceBaseExample.GetResourceIdPropertyName())" |
                    Should -BeNullOrEmpty
            }

        }

    }
}
