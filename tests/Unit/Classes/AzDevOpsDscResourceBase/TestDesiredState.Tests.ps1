using module ..\..\..\..\output\AzureDevOpsDsc\0.2.0\Classes\AzDevOpsDscResourceBase\AzDevOpsDscResourceBase.psm1

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


    Describe "$script:subModuleName\Classes\AzDevOpsDscResourceBase\$script:commandName" -Tag $script:tag {

        class AzDevOpsDscResourceBaseExample : AzDevOpsDscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
        {
            [string]$ApiUri = 'https://some.api/_apis/'
            [string]$Pat = '1234567890123456789012345678901234567890123456789012'

            [DscProperty(Key)]
            [string]$AzDevOpsDscResourceBaseExampleName = 'AzDevOpsDscResourceBaseExampleNameValue'

            [string]$AzDevOpsDscResourceBaseExampleId # = '31e71307-09b3-4d8a-b65c-5c714f64205f' # Random GUID

            [string]GetResourceName()
            {
                return 'AzDevOpsDscResourceBaseExample'
            }

            [Hashtable]GetDscCurrentStateObjectGetParameters()
            {
                return @{}
            }

            [PSObject]GetDscCurrentStateResourceObject([Hashtable]$GetParameters)
            {
                return $null
            }
        }

        $testCasesValidButNotNone = @(
            @{
                RequiredAction = [RequiredAction]::Get
            },
            @{
                RequiredAction = [RequiredAction]::New
            },
            @{
                RequiredAction = [RequiredAction]::Set
            },
            @{
                RequiredAction = [RequiredAction]::Remove
            },
            @{
                RequiredAction = [RequiredAction]::Test
            },
            @{
                RequiredAction = [RequiredAction]::Error
            }
        )

        Context 'When no "GetDscRequiredAction()" returns "None"'{

            It 'Should not throw' {

                $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
                [ScriptBlock]$getDscRequiredAction = {return [RequiredAction]::None}
                $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name GetDscRequiredAction -Value $getDscRequiredAction -Force

                {$azDevOpsDscResourceBase.TestDesiredState()} | Should -Not -Throw
            }

            It 'Should return $true' {

                $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
                [ScriptBlock]$getDscRequiredAction = {return [RequiredAction]::None}
                $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name GetDscRequiredAction -Value $getDscRequiredAction -Force

                $azDevOpsDscResourceBase.TestDesiredState() | Should -BeTrue
            }

        }


        Context 'When no "GetDscRequiredAction()" does not return "None"'{

            It 'Should not throw - "<RequiredAction>"' -TestCases $testCasesValidButNotNone {
                param ([RequiredAction]$RequiredAction)

                $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
                [ScriptBlock]$getDscRequiredAction = {return $RequiredAction}
                $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name GetDscRequiredAction -Value $getDscRequiredAction -Force

                {$azDevOpsDscResourceBase.TestDesiredState()} | Should -Not -Throw
            }

            It 'Should return $false - "<RequiredAction>"' -TestCases $testCasesValidButNotNone {
                param ([RequiredAction]$RequiredAction)

                $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
                [ScriptBlock]$getDscRequiredAction = {return $RequiredAction}
                $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name GetDscRequiredAction -Value $getDscRequiredAction -Force

                $azDevOpsDscResourceBase.TestDesiredState() | Should -BeFalse
            }

        }

    }
}
