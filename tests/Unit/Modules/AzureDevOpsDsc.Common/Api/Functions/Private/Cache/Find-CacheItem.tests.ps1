$currentFile = $MyInvocation.MyCommand.Path

# Find-CacheItem.Tests.ps1

# Import the module or the script containing the function
# Import-Module 'Path\To\Your\Module.psd1' or . .\Path\To\YourScript.ps1

Describe 'Find-CacheItem' -Tags "Unit", "Cache" {

    AfterAll {
        Remove-Variable -Name AzDoProject -ErrorAction SilentlyContinue
    }

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Find-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        $testCacheList = @(
            [PSCustomObject]@{ Name = 'Item1'; Value = @{ Name = 'Value1' } },
            [PSCustomObject]@{ Name = 'Item2'; Value = @{ Name = 'Value2' } },
            [PSCustomObject]@{ Name = 'MyCacheItem'; Value = @{ Name = 'MyValue' } }
        )

    }

    Context 'When a matching item exists' {

        It 'Returns the matching item' {

            $filter = { $_.Value.Name -eq 'MyValue' }
            $result = $testCacheList | Find-CacheItem -Filter $filter
            $result | Should -HaveCount 1
            $result.Name | Should -Be 'MyCacheItem'
        }

    }

    Context 'When no matching item exists' {
        It 'Returns an empty array' {
            $filter = { $_.Name -eq 'NonExistentItem' }
            $result = $testCacheList | Find-CacheItem -Filter $filter
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'With an empty cache list' {
        It 'Returns an empty array' {
            $emptyCacheList = @()
            $filter = { $_.Name -eq 'AnyItem' }
            $result = $emptyCacheList | Find-CacheItem -Filter $filter
            $result | Should -BeNullOrEmpty
        }
    }
}
