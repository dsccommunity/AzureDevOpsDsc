$currentFile = $MyInvocation.MyCommand.Path

Describe "Export-CacheObject" -Tags "Unit", "Cache" {

    AfterAll {
        Remove-Variable -Name AzDoProject -ErrorAction SilentlyContinue
    }

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Export-CacheObject.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mock dependencies
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Project', 'Team', 'Group', 'SecurityDescriptor') } -Verifiable
        Mock -CommandName Test-Path -MockWith { param ($Path) return $false } -Verifiable
        Mock -CommandName New-Item -MockWith { param ($Path, $ItemType) } -Verifiable
        Mock -CommandName Export-Clixml -MockWith { param ($InputObject, $Depth, $LiteralPath) } -Verifiable

    }

    BeforeEach {
        $env:AZDODSC_CACHE_DIRECTORY = "C:\MockPath\AzDoCache"
    }

    AfterEach {
        Remove-Variable -Name AZDODSC_CACHE_DIRECTORY -ErrorAction SilentlyContinue
    }

    Context "when the environment variable AZDODSC_CACHE_DIRECTORY is not set" {
        BeforeEach {
            $env:AZDODSC_CACHE_DIRECTORY = $null
        }

        It "should throw an error" {
            { Export-CacheObject -CacheType 'Project' -Content @() } | Should -Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set. Please set the variable to the path of the cache directory."
        }
    }

    Context "when the environment variable AZDODSC_CACHE_DIRECTORY is set" {
        BeforeEach {
            $env:AZDODSC_CACHE_DIRECTORY = "C:\Temp\AzDoCache"
        }

        It "should create the cache directory if it does not exist" {
            Mock -CommandName Test-Path -MockWith { param ($Path) return $false } -Verifiable
            Mock -CommandName New-Item -Verifiable

            Export-CacheObject -CacheType 'Project' -Content @()

            Assert-MockCalled -CommandName New-Item -Exactly 1 -ParameterFilter {
                $Path     -eq "C:\Temp\AzDoCache\Cache" -and
                $ItemType -eq "Directory"
            }
        }

        It "should not create the cache directory if it already exists" {
            Mock -CommandName Test-Path -MockWith { param ($Path) return $true } -Verifiable
            Mock -CommandName New-Item

            Export-CacheObject -CacheType 'Project' -Content @()

            Assert-MockCalled -CommandName New-Item -Exactly 0 -Scope It
        }

        It "should save content to the cache file" {

            Mock -CommandName Export-Clixml -Verifiable

            $content = @(
                [PSCustomObject]@{ Name = 'Project1'; Id = 1 },
                [PSCustomObject]@{ Name = 'Project2'; Id = 2 }
            )

            Export-CacheObject -CacheType 'Project' -Content $content
            Assert-MockCalled -CommandName Export-Clixml -Times 1

        }

        It "should use the default depth value of 3" {

            Mock -CommandName Export-Clixml

            $content = @(
                [PSCustomObject]@{ Name = 'Project1'; Id = 1 },
                [PSCustomObject]@{ Name = 'Project2'; Id = 2 }
            )

            Export-CacheObject -CacheType 'Project' -Content $content

            Assert-MockCalled -CommandName Export-Clixml -Times 1 -ParameterFilter {
                $Depth       -eq 3 -and
                $LiteralPath -eq "C:\Temp\AzDoCache\Cache\Project.clixml"
            }
        }

        It "should use the specified depth value" {

            Mock -CommandName Export-Clixml

            $content = @(
                [PSCustomObject]@{ Name = 'Project1'; Id = 1 },
                [PSCustomObject]@{ Name = 'Project2'; Id = 2 }
            )

            Export-CacheObject -CacheType 'Project' -Content $content -Depth 5

            Assert-MockCalled -CommandName Export-Clixml -Times 1 -ParameterFilter {
                $Depth       -eq 5 -and
                $LiteralPath -eq "C:\Temp\AzDoCache\Cache\Project.clixml"
            }
        }
    }

    Context "when invalid CacheType is provided" {
        It "should throw an error" {
            { Export-CacheObject -CacheType 'InvalidType' -Content @() } | Should -Throw
        }
    }
}
