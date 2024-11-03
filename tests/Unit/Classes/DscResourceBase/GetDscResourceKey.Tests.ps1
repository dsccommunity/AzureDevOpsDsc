Describe "[DscResourceBase]::GetDscResourceKey() Tests" -Tag 'Unit', 'DscResourceBase' {


    Context 'When called from instance of the class without a DSC Resource key' {

        It 'Should throw' {

            $dscResourceBase = [DscResourceBase]::new()
            {$dscResourceBase.GetDscResourceKey()} | Should -Throw
        }


        Context 'When "GetDscResourceKeyPropertyName" returns a $null value' {

            It 'Should throw' {

                $dscResourceBase = [DscResourceBase]::new()
                $dscResourceBase | Add-Member -MemberType ScriptMethod 'GetDscResourceKeyPropertyName' -Value { return $null } -Force

                {$dscResourceBase.GetDscResourceKey()} | Should -Throw
            }
        }


        Context 'When "GetDscResourceKeyPropertyName" returns a "" (empty string) value' {

            It 'Should throw' {

                $dscResourceBase = [DscResourceBase]::new()
                $dscResourceBase | Add-Member -MemberType ScriptMethod 'GetDscResourceKeyPropertyName' -Value { return '' } -Force

                {$dscResourceBase.GetDscResourceKey()} | Should -Throw
            }
        }



    }


    Context 'When called from instance of a class with multiple DSC Resource keys' {

        It 'Should throw' {

            class DscResourceBase2DscKeys : DscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [DscProperty(Key)]
                [string]$DscKey1

                [DscProperty(Key)]
                [string]$DscKey2
            }
            $dscResourceWith2Keys = [DscResourceBase2DscKeys]@{}
            {$dscResourceWith2Keys.GetDscResourceKey()} | Should -Throw
        }

    }


    Context 'When called from instance of class with a DSC key' {

        BeforeAll {
            class DscResourceBase1DscKey : DscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
            {
                [DscProperty(Key)]
                [string]$DscKey1
            }

            $dscResourceWith1Key = [DscResourceBase1DscKey]@{
                DscKey1='DscKey1Value'
            }
        }

        It 'Should not throw' {

            $dscResourceWith1Key.GetDscResourceKey()
            {$dscResourceWith1Key.GetDscResourceKey()} | Should -Not -Throw
        }

        It 'Should return the value of the DSC Resource key' {

            $dscResourceWith1Key.GetDscResourceKey() | Should -Be 'DscKey1Value'
        }
    }
}
