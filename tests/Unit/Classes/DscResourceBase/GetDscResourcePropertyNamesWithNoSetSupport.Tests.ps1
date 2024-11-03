Describe "[DscResourceBase]::GetDscResourcePropertyNamesWithNoSetSupport() Tests" -Tag 'Unit', 'DscResourceBase' {


    Context 'When called from instance of a class without any DSC properties with no "Set" support' {

        It 'Should not throw' {

            $dscResourceWithNoSetSupportProperties = [DscResourceBase]::new()

            {$dscResourceWithNoSetSupportProperties.GetDscResourcePropertyNamesWithNoSetSupport()} | Should -Not -Throw
        }

        It 'Should return empty array' {

            $dscResourceWithNoSetSupportProperties = [DscResourceBase]::new()

            $dscResourceWithNoSetSupportProperties.GetDscResourcePropertyNamesWithNoSetSupport().Count | Should -Be 0
        }
    }


    Context 'When called from instance of a class with a DSC property with no "Set" support' {

        class DscResourceBaseWithNoSet : DscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
        {
            [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
            {
                return @('NoSetPropertyName1', 'NoSetPropertyName2')
            }
        }

        It 'Should not throw' {

            $dscResourceWithANoSetSupportProperty = [DscResourceBaseWithNoSet]@{}

            { $dscResourceWithANoSetSupportProperty.GetDscResourcePropertyNamesWithNoSetSupport() } | Should -Not -Throw
        }

        It 'Should return the correct number of DSC resource property names that do not support "SET"' {

            $dscResourceWithANoSetSupportProperty = [DscResourceBaseWithNoSet]@{}

            $dscResourceWithANoSetSupportProperty.GetDscResourcePropertyNamesWithNoSetSupport().Count | Should -Be 2
        }

        It 'Should return the correct DSC resource property names that do not support "SET"' {

            $dscResourceWithANoSetSupportProperty = [DscResourceBaseWithNoSet]@{}

            $propertyNames = $dscResourceWithANoSetSupportProperty.GetDscResourcePropertyNamesWithNoSetSupport()

            $propertyNames | Should -Contain 'NoSetPropertyName1'
            $propertyNames | Should -Contain 'NoSetPropertyName2'
        }
    }
}
