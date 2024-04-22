<#
    .SYNOPSIS
        Tests for the 'DscResourceBase' class to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the class methods correctly identify DSC resource key properties,
        DSC resource property names, and handle exceptions appropriately.
#>

Describe "DscResourceBase Tests" {

    BeforeAll {
        # Define a mock attribute to simulate DscPropertyAttribute
        class DscPropertyAttribute : System.Attribute {
            [bool]$Key
        }

        # Define a mock class inheriting from DscResourceBase for testing purposes
        class MockDscResource : DscResourceBase {
            [DscProperty(Key=$true)]
            [string]$KeyProperty = "KeyValue"

            [DscProperty()]
            [string]$OtherProperty = "OtherValue"
        }
    }

    It "Should return the DSC resource key property name" {
        $mockResource = [MockDscResource]::new()
        $keyPropertyName = $mockResource.GetDscResourceKeyPropertyName()

        $keyPropertyName | Should -BeExactly "KeyProperty"
    }

    It "Should throw an exception if no DSC resource key property is found" {
        class MockDscResourceNoKey : DscResourceBase {
            [DscProperty()]
            [string]$OtherProperty = "OtherValue"
        }

        { [MockDscResourceNoKey]::new().GetDscResourceKeyPropertyName() } | Should -Throw
    }

    It "Should throw an exception if more than one DSC resource key property is found" {
        class MockDscResourceMultipleKeys : DscResourceBase {
            [DscProperty(Key=$true)]
            [string]$FirstKeyProperty = "FirstKeyValue"

            [DscProperty(Key=$true)]
            [string]$SecondKeyProperty = "SecondKeyValue"
        }

        { [MockDscResourceMultipleKeys]::new().GetDscResourceKeyPropertyName() } | Should -Throw
    }

    It "Should return the value of the DSC resource key property" {
        $mockResource = [MockDscResource]::new()
        $keyPropertyValue = $mockResource.GetDscResourceKey()

        $keyPropertyValue | Should -BeExactly "KeyValue"
    }

    It "Should return all DSC resource property names" {
        $mockResource = [MockDscResource]::new()
        $propertyNames = $mockResource.GetDscResourcePropertyNames()

        $propertyNames.Count | Should -Be 2
        $propertyNames | Should -Contain "KeyProperty"
        $propertyNames | Should -Contain "OtherProperty"
    }

    It "Should return an empty array when there are no properties without set support" {
        $mockResource = [MockDscResource]::new()
        $noSetSupportProperties = $mockResource.GetDscResourcePropertyNamesWithNoSetSupport()

        $noSetSupportProperties | Should -Be @()
    }
}

# To execute these tests, save the above code in a file with a .Tests.ps1 extension, such as `DscResourceBase.Tests.ps1`, and run `Invoke-Pester` in the directory containing the test script.
