
$hereScript = @"
Function Test-Initialize-CacheObject {

    Describe "Initialize-CacheObject Tests" {

        BeforeAll {
            Function Get-AzDoCacheObjects {
                return @('Project', 'Team', 'Group', 'SecurityDescriptor')
            }
            Function Import-CacheObject {
                param (
                    [string]$CacheType
                )
            }
            Function Set-CacheObject {
                param (
                    [string]$CacheType,
                    [Object]$Content
                )
            }
            $ENV:AZDODSC_CACHE_DIRECTORY = "C:\CacheDir"
            $mockPath = "C:\CacheDir\Cache"
            $null = New-Item -Path $($mockPath) -ItemType Directory -Force
        }

        AfterAll {
            Remove-Item -Path "C:\CacheDir" -Recurse -Force
        }

        Context "When Cache File Does Not Exist" {

            It "Should Create Cache Directory If Not Exists" {
                { Initialize-CacheObject -CacheType Project } | Should -Not -Throw
                Test-Path -Path "$mockPath\Project.clixml" | Should -Be $true
            }

            It "Should Create New Cache Object" {
                { Initialize-CacheObject -CacheType Project } | Should -Not -Throw
                # Any additional assertions to check if the Set-CacheObject function is called correctly
            }
        }

        Context "When Cache File Exists" {

            BeforeEach {
                New-Item -Path "$mockPath\Project.clixml" -ItemType File -Force | Out-Null
            }

            It "Should Import Cache Object" {
                { Initialize-CacheObject -CacheType Project } | Should -Not -Throw
                # Any additional assertions to check if the Import-CacheObject function is called correctly
            }
        }

        Context "When Environment Variable Not Set" {

            BeforeEach {
                $ENV:AZDODSC_CACHE_DIRECTORY = $null
            }

            It "Should Throw Error" {
                { Initialize-CacheObject -CacheType Project } | Should -Throw "The environment variable 'AZDODSC_CACHE_DIRECTORY' is not set."
            }
        }

        Context "When BypassFileCheck is Present" {

            BeforeEach {
                New-Item -Path "$mockPath\LiveProjects.clixml" -ItemType File -Force | Out-Null
            }

            It "Should Remove Cache File for Live Cache Types Without Bypassing" {
                { Initialize-CacheObject -CacheType LiveProjects -Verbose: $true } | Should -Not -Throw
                Test-Path -Path "$mockPath\LiveProjects.clixml" | Should -Be $false
            }

            It "Should Not Remove Cache File for Live Cache Types When BypassFileCheck is Present" {
                { Initialize-CacheObject -CacheType LiveProjects -BypassFileCheck -Verbose: $true } | Should -Not -Throw
                Test-Path -Path "$mockPath\LiveProjects.clixml" | Should -Be $true
            }
        }
    }
}

Test-Initialize-CacheObject
"@

Invoke-Expression $hereScript

