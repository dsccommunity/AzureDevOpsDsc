$currentFile = $MyInvocation.MyCommand.Path

Describe "Initialize-CacheObject Tests" {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Find-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mock the necessary Commands and Variables
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('LiveProject', 'Project', 'Team', 'Group', 'SecurityDescriptor') }
        Mock -CommandName Test-Path -MockWith { param($Path) return $false }
        Mock -CommandName Import-CacheObject
        Mock -CommandName Set-CacheObject
        Mock -CommandName Remove-Item
        Mock -CommandName New-Item
        $ENV:AZDODSC_CACHE_DIRECTORY = 'C:\Cache'
    }

    Context "Valid CacheType parameter" {

        It "Imports the cache object if cache file exists" {

            Mock Test-Path { $true }

            Initialize-CacheObject -CacheType 'Project'

            Assert-MockCalled -CommandName Import-CacheObject -Exactly 1
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 0
        }

        It "Creates a new cache object if cache file does not exist" {
            Mock Test-Path { $false }

            Initialize-CacheObject -CacheType 'Project'

            Assert-MockCalled -CommandName Import-CacheObject -Exactly 0
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 1
        }

        It "Removes cache file if BypassFileCheck is not present and CacheType matches '^Live'" {
            Mock Test-Path -MockWith { $true }

            Wait-Debugger
            Initialize-CacheObject -CacheType 'LiveProject'

            Assert-MockCalled -CommandName Remove-Item -Exactly 1
            Assert-MockCalled -CommandName Import-CacheObject -Exactly 0
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 1
        }
    }

    Context "Environment variable not set" {
        BeforeEach {
            $ENV:AZDODSC_CACHE_DIRECTORY = $null
        }

        It "Throws an exception if the environment variable is not set" {
            {
                Initialize-CacheObject -CacheType 'Project'
            } | Should -Throw -ErrorMessage "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
        }
    }

    Context "BypassFileCheck switch" {

        It "Does not remove cache file if BypassFileCheck is present" {
            Mock Test-Path { $true } -ParameterFilter { $_ -eq 'C:\Cache\Cache\LiveProjects.clixml' }

            Initialize-CacheObject -CacheType 'LiveProjects' -BypassFileCheck

            Assert-MockCalled -CommandName Remove-Item -Exactly 0
            Assert-MockCalled -CommandName Import-CacheObject -Exactly 1
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 0
        }
    }

}
