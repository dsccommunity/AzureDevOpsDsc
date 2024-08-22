$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-CacheObject Tests' {

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

        $ENV:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"

        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Project', 'Team', 'Group', 'SecurityDescriptor') }
        Mock -CommandName Import-CacheObject

    }

    AfterAll {
        if ($originalEnvironment) {
            Set-Variable -Name "ENV" -Value $originalEnvironment -Scope Global
        }
    }

    It 'Should throw error if environment variable is not set' {
        $ENV:AZDODSC_CACHE_DIRECTORY = $null
        { Get-CacheObject -CacheType 'Project' } | Should -Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
    }

    It 'Should return cache object from memory if available' {
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
        Set-Variable -Name "AzDoProject" -Value "ProjectCache" -Scope Global
        $result = Get-CacheObject -CacheType 'Project'
        $result | Should -Be "ProjectCache"
        Remove-Variable -Name "AzDoProject" -Scope Global -ErrorAction SilentlyContinue
    }

    It 'Should import cache object if not available in memory' {
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
        Mock -CommandName Import-CacheObject -MockWith { return "ImportedProjectCache" }

        $result = Get-CacheObject -CacheType 'Project'
        $result | Should -Be "ImportedProjectCache"
    }
}
