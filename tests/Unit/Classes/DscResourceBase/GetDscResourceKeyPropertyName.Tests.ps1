Describe "[DscResourceBase]::GetDscResourceKeyPropertyName() Tests" -Tag 'Unit', 'DscResourceBase' {


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

        BeforeAll {
            class DscResourceBase1Key : DscResourceBase
            {
                [DscProperty(Key)]
                [string]$DscKey1
            }

            $dscResourceWith1Key = [DscResourceBase1Key]@{
                DscKey1 = 'DscKey1Value'
            }
        }

        It 'Should not throw' {
            $dscResourceWith1Key.GetDscResourceKeyPropertyName()
            {$dscResourceWith1Key.GetDscResourceKeyPropertyName()} | Should -Not -Throw
        }

        It 'Should return the value of the DSC Resource key' {

            $dscResourceWith1Key.GetDscResourceKeyPropertyName() | Should -Be 'DscKey1'
        }
    }
}
