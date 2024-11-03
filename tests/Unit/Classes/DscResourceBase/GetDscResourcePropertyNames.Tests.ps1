Describe "[DscResourceBase]::GetDscResourcePropertyNames() Tests" -Tag 'Unit', 'DscResourceBase' {


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

        BeforeAll {
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
