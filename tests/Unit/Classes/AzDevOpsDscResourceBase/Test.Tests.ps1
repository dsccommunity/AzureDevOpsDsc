
Describe "[AzDevOpsDscResourceBase]::Test() Tests" -Tag 'Unit', 'AzDevOpsDscResourceBase' {

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

    Context 'When no "TestDesiredState()" returns $true'{

        It 'Should not throw' {

            $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
            [ScriptBlock]$testDesiredState = {return $true}
            $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name TestDesiredState -Value $testDesiredState -Force

            { $azDevOpsDscResourceBase.Test() } | Should -BeTrue
        }

        It 'Should return $true' {

            $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
            [ScriptBlock]$testDesiredState = {return $true}
            $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name TestDesiredState -Value $testDesiredState -Force

            $azDevOpsDscResourceBase.Test() | Should -BeTrue
        }

    }


    Context 'When no "TestDesiredState()" returns $false'{

        It 'Should not throw' {

            $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
            [ScriptBlock]$testDesiredState = {return $false}
            $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name TestDesiredState -Value $testDesiredState -Force

            { $azDevOpsDscResourceBase.Test() } | Should -Not -Throw
        }

        It 'Should return $false' {

            $azDevOpsDscResourceBase = [AzDevOpsDscResourceBaseExample]::new()
            [ScriptBlock]$testDesiredState = {return $false}
            $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name TestDesiredState -Value $testDesiredState -Force

            $azDevOpsDscResourceBase.Test() | Should -BeFalse
        }

    }

}

