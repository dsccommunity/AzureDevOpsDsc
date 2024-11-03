# Tests for Refresh-CacheObject function

# Import the module containing the Refresh-CacheObject function if necessary
# Import-Module YourModuleName

$currentFile = $MyInvocation.MyCommand.Path


Describe "Refresh-CacheObject" -tags Unit, Cache {

    AfterAll {
        Remove-Variable -Name AzDoProject -ErrorAction SilentlyContinue
    }

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Refresh-CacheObject.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mock the Get-AzDoCacheObjects function to return a list of valid cache types
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Type1', 'Type2', 'Type3') }

        # Mock the Remove-Variable cmdlet to prevent actual removal of variables
        Mock -CommandName Remove-Variable

        # Mock the Import-CacheObject function to prevent actual import actions
        Mock -CommandName Import-CacheObject

    }

    Context "When CacheType is valid" {
        It "Should unload and reload the cache object of type 'Type1'" {
            $cacheType = 'Type1'
            Refresh-CacheObject -CacheType $cacheType

            # Verify that Remove-Variable was called with the correct parameters
            Assert-MockCalled -CommandName Remove-Variable -Exactly 1 -ParameterFilter { $Name -eq "AzDoType1" }

            # Verify that Import-CacheObject was called with the correct parameter
            Assert-MockCalled -CommandName Import-CacheObject -Exactly 1 -ParameterFilter { $CacheType -eq 'Type1' }
        }

        It "Should unload and reload the cache object of type 'Type2'" {
            $cacheType = 'Type2'
            Refresh-CacheObject -CacheType $cacheType

            # Verify that Remove-Variable was called with the correct parameters
            Assert-MockCalled -CommandName Remove-Variable -Exactly 1 -ParameterFilter { $Name -eq "AzDoType2" }

            # Verify that Import-CacheObject was called with the correct parameter
            Assert-MockCalled -CommandName Import-CacheObject -Exactly 1 -ParameterFilter { $CacheType -eq 'Type2' }
        }
    }

}
