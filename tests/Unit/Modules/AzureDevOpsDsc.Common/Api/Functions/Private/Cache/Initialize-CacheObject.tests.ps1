$currentFile = $MyInvocation.MyCommand.Path

Describe "Initialize-CacheObject Tests" -Tags "Unit", "Cache" {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-CacheObject.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mock the necessary Commands and Variables
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('LiveProject', 'LiveProjects', 'Project', 'Team', 'Group', 'SecurityDescriptor') }
        Mock -CommandName Test-Path -MockWith { param($Path) return $false }
        Mock -CommandName Import-CacheObject
        Mock -CommandName Set-CacheObject
        Mock -CommandName Remove-Item
        Mock -CommandName New-Item

        $ENV:AZDODSC_CACHE_DIRECTORY = 'C:\Cache'

    }

    AfterAll {
        Remove-Variable -Name AzDoProject -ErrorAction SilentlyContinue
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
            Mock Test-Path -MockWith { $true } -ParameterFilter { $ErrorAction -eq 'SilentlyContinue' }
            Mock Test-Path -MockWith { $false } -ParameterFilter { $Path -eq 'C:\Cache\Cache\LiveProject.clixml' }

            Initialize-CacheObject -CacheType 'LiveProject'

            Assert-MockCalled -CommandName Remove-Item -Times 1
            Assert-MockCalled -CommandName Import-CacheObject -Exactly 0
            Assert-MockCalled -CommandName Set-CacheObject -Times 1
        }
    }

    Context "Environment variable not set" {
        BeforeEach {
            $ENV:AZDODSC_CACHE_DIRECTORY = $null
        }

        It "Throws an exception if the environment variable is not set" {
            {
                Initialize-CacheObject -CacheType 'Project'
            } | Should -Throw "*The environment variable `'AZDODSC_CACHE_DIRECTORY`' is not set.*"
        }
    }

    Context "BypassFileCheck switch" {

        BeforeAll {
            $ENV:AZDODSC_CACHE_DIRECTORY = 'C:\Cache'
        }

        It "Does not remove cache file if BypassFileCheck is present" {
            Mock Test-Path { $true } -ParameterFilter { $Path -ne $null }

            Initialize-CacheObject -CacheType 'LiveProjects' -BypassFileCheck

            Assert-MockCalled -CommandName Remove-Item -Exactly 0
            Assert-MockCalled -CommandName Import-CacheObject -Exactly 1
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 0
        }
    }

}
