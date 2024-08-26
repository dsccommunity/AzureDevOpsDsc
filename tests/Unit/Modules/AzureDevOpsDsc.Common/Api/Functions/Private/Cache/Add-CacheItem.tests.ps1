$currentFile = $MyInvocation.MyCommand.Path

Describe "Add-CacheItem" -Tags "Unit", "Cache" {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mock dependencies
        Mock -CommandName Get-CacheObject -MockWith { return @() }

    }

    Context "when adding a new cache item" {

        BeforeEach {
            $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global
        }

        It "should retrieve the current cache" {
            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'

            Assert-MockCalled -CommandName Get-CacheObject -Exactly 1 -ParameterFilter {
                $CacheType -eq 'Project'
            }
        }

        It "should create a new cache if the current cache is empty" {
            Mock -CommandName Get-CacheObject -MockWith { return @() }
            Mock -CommandName Write-Verbose
            Mock -CommandName Set-Variable -Verifiable

            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'

            Assert-MockCalled -CommandName Write-Verbose -Exactly 1 -ParameterFilter {
                $Message -eq '[Add-CacheItem] Cache is empty. Creating new cache.'
            }

        }

        It "should add a new cache item with the correct key and value" {
            Mock -CommandName Get-CacheObject -MockWith { return @() }
            Mock -CommandName Write-Verbose

            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'

            $cache = Get-Variable -Name "AzDoProject" -Scope Global -ValueOnly
            $cache[0].Key | Should -Be 'MyKey'
            $cache[0].Value | Should -Be 'MyValue'
        }
    }

    Context "when the cache already contains the key" {

        BeforeEach {
            Mock -CommandName Get-CacheObject -MockWith {
                return $Global:AzDoProject
            }
        }

        AfterEach {
            Remove-Variable -Name "AzDoProject" -Scope Global
        }

        It "should remove the existing cache item" {
            Mock -CommandName Write-Verbose
            Mock -CommandName Write-Warning
            Mock -CommandName Remove-CacheItem -Verifiable -MockWith {
                $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global
            }

            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'
            Add-CacheItem -Key 'MyKey' -Value 'NewValue' -Type 'Project'

            $cache = Get-Variable -Name "AzDoProject" -Scope Global -ValueOnly
            $cache[0].Key | Should -Be 'MyKey'
            $cache[0].Value | Should -Be 'NewValue'

        }

        It "should add the new cache item after removing the old one" {
            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'

            $cache = Get-Variable -Name "AzDoProject" -Scope Global -ValueOnly
            $cache[0].Key | Should -Be 'MyKey'
            $cache[0].Value | Should -Be 'MyValue'
        }

        It "should suppress the warning if SuppressWarning switch is present" {
            Mock -CommandName Write-Warning
            Mock -CommandName Write-Verbose

            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project' -SuppressWarning
            Add-CacheItem -Key 'MyKey' -Value 'NewValue' -Type 'Project' -SuppressWarning

            Assert-MockCalled -CommandName Write-Warning -Exactly 0
            Assert-MockCalled -CommandName Write-Verbose -Times 3

        }

        It "should display a warning if SuppressWarning switch is not present" {
            Mock -CommandName Write-Warning

            Add-CacheItem -Key 'MyKey' -Value 'MyValue' -Type 'Project'
            Add-CacheItem -Key 'MyKey' -Value 'NewValue' -Type 'Project'

            Assert-MockCalled -CommandName Write-Warning -Exactly 1
        }
    }

}
