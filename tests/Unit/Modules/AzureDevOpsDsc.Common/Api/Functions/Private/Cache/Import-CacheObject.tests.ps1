Describe "Import-CacheObject Tests" {
    BeforeAll {
        # Mock the necessary Commands and Variables
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Project', 'Team', 'Group', 'SecurityDescriptor') }
        Mock -CommandName Test-Path -MockWith { return $true }
        Mock -CommandName Import-Clixml -MockWith { return @([PSCustomObject]@{ Key = 'Key1'; Value = 'Value1' }, [PSCustomObject]@{ Key = 'Key2'; Value = 'Value2' }) }
        Mock -CommandName Set-Variable
        $ENV:AZDODSC_CACHE_DIRECTORY = 'C:\Cache'
    }

    Context "Valid CacheType parameter" {

        It "Imports the cache object successfully" {
            Import-CacheObject -CacheType 'Project'

            Assert-MockCalled -CommandName Test-Path -Exactly 1
            Assert-MockCalled -CommandName Import-Clixml -Exactly 1
            Assert-MockCalled -CommandName Set-Variable -Exactly 1
        }

        It "Sets the correct variable name and value" {
            Import-CacheObject -CacheType 'Team'

            Assert-MockCalled -CommandName Set-Variable -Exactly 1 -ParameterFilter {
                $Name -eq 'AzDoTeam' -and $Scope -eq 'Global' -and $Force -eq $true
            }
        }
    }

    Context "Cache file not found" {
        BeforeEach {
            Mock -CommandName Test-Path -MockWith { return $false }
            Mock -CommandName Write-Warning
        }

        It "Writes a warning when cache file is not found" {
            Import-CacheObject -CacheType 'Project'

            Assert-MockCalled -CommandName Write-Warning -Exactly 1 -ParameterFilter {
                $_ -match 'Cache file not found'
            }
        }
    }

    Context "Environment variable not set" {
        BeforeEach {
            $ENV:AZDODSC_CACHE_DIRECTORY = $null
        }

        It "Throws an exception if the environment variable is not set" {
            {
                Import-CacheObject -CacheType 'Project'
            } | Should -Throw
        }
    }

    AfterAll {
        # Clean up Mock and Env
        Remove-Variable -Name AZDODSC_CACHE_DIRECTORY
        Unmock-Command -CommandName Get-AzDoCacheObjects
        Unmock-Command -CommandName Test-Path
        Unmock-Command -CommandName Import-Clixml
        Unmock-Command -CommandName Set-Variable
    }
}

