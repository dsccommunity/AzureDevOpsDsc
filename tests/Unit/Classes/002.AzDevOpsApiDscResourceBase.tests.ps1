<#
    .SYNOPSIS
        Tests for the 'AzDevOpsApiDscResourceBase' class to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the class methods correctly derive resource names, IDs, keys,
        and function names based on the naming conventions and properties defined.
#>

Describe "AzDevOpsApiDscResourceBase Tests" {

    BeforeAll {
        # Define a mock attribute to simulate DscPropertyAttribute
        class DscPropertyAttribute : System.Attribute {
            [bool]$Key
        }

        # Define an enum to simulate RequiredAction
        enum RequiredAction {
            Get
            New
            Set
            Remove
            Test
        }

        # Define a mock class inheriting from AzDevOpsApiDscResourceBase for testing purposes
        class MockAzDevOpsResource : AzDevOpsApiDscResourceBase {
            [DscProperty(Key=$true)]
            [string]$MockAzDevOpsId = "MockId"
        }
    }

    It "Should return the correct resource name without the 'AzDevOps' prefix" {
        $mockResource = [MockAzDevOpsResource]::new()
        $resourceName = $mockResource.GetResourceName()

        $resourceName | Should -BeExactly "Mock"
    }

    It "Should return the correct ResourceId property name" {
        $mockResource = [MockAzDevOpsResource]::new()
        $resourceIdPropertyName = $mockResource.GetResourceIdPropertyName()

        $resourceIdPropertyName | Should -BeExactly "MockId"
    }

    It "Should return the correct ResourceKey property value" {
        $mockResource = [MockAzDevOpsResource]::new()
        $resourceKeyPropertyValue = $mockResource.GetResourceKey()

        $resourceKeyPropertyValue | Should -BeExactly "MockId"
    }

    It "Should return the correct ResourceKey property name" {
        $mockResource = [MockAzDevOpsResource]::new()
        $resourceKeyPropertyName = $mockResource.GetResourceKeyPropertyName()

        $resourceKeyPropertyName | Should -BeExactly "MockAzDevOpsId"
    }

    It "Should return the correct function name for each RequiredAction" {
        $mockResource = [MockAzDevOpsResource]::new()

        @([RequiredAction]::Get, [RequiredAction]::New, [RequiredAction]::Set, [RequiredAction]::Remove, [RequiredAction]::Test) | ForEach-Object {
            $action = $_
            $functionName = $mockResource.GetResourceFunctionName($action)

            $functionName | Should -BeExactly "$($action)-Mock"
        }
    }

    It "Should return null for an invalid RequiredAction" {
        $mockResource = [MockAzDevOpsResource]::new()
        $invalidAction = [RequiredAction]::Remove + 1 # Assuming there is no such action in the enum

        $functionName = $mockResource.GetResourceFunctionName($invalidAction)

        $functionName | Should -Be $null
    }
}

# To execute these tests, save the above code in a file with a .Tests.ps1 extension, such as `AzDevOpsApiDscResourceBase.Tests.ps1`, and run `Invoke-Pester` in the directory containing the test script.
