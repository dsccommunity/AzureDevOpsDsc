$currentFile = $MyInvocation.MyCommand.Path

# Import the module containing Set-AzDoProjectGroup if it's in a different file.
# . .\path\to\your\module.psm1

Describe 'Set-AzDoProjectGroup' {

    AfterAll {
        # Clean up
        Remove-Variable -Name DSCAZDO_OrganizationName -ErrorAction SilentlyContinue
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzDoProjectGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')


        # Mocking external functions that are called within the function
        Mock -CommandName Set-DevOpsGroup -MockWith {
            return @{ principalName = 'newPrincipal'; descriptor = 'newDescriptor'; }
        }

        Mock -CommandName Refresh-CacheIdentity
        Mock -CommandName Remove-CacheItem
        Mock -CommandName Add-CacheItem
        Mock -CommandName Set-CacheObject
        Mock -CommandName Write-Warning

    }

    Context 'When LookupResult status is Renamed' {
        It 'Should write a warning and return without making any API calls' {
            $LookupResult = @{
                Status = [DSCGetSummaryState]::Renamed
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
            }

            $result = Set-AzDoProjectGroup -GroupName 'TestGroup' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Set-DevOpsGroup -Times 0 -Exactly
            Assert-MockCalled -CommandName Refresh-CacheIdentity -Times 0 -Exactly
            Assert-MockCalled -CommandName Remove-CacheItem -Times 0 -Exactly
            Assert-MockCalled -CommandName Add-CacheItem -Times 0 -Exactly
            Assert-MockCalled -CommandName Set-CacheObject -Times 0 -Exactly
        }
    }

    Context 'When updating the group' {
        It 'Should call Set-DevOpsGroup with correct parameters and update caches' {
            $LookupResult = @{
                Status = [DSCGetSummaryState]::Existing
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
                localCache = @{
                    principalName = 'localPrincipal'
                }
            }

            $Global:DSCAZDO_OrganizationName = 'TestOrg'

            $result = Set-AzDoProjectGroup -GroupName 'TestGroup' -GroupDescription 'TestDescription' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Set-DevOpsGroup -Times 1 -Exactly -ParameterFilter {
                ($ApiUri -eq "https://vssps.dev.azure.com/TestOrg") -and
                ($GroupName -eq 'TestGroup') -and
                ($GroupDescription -eq 'TestDescription') -and
                ($GroupDescriptor -eq 'liveDescriptor')
            }

            Assert-MockCalled -CommandName Refresh-CacheIdentity -Times 1 -Exactly -ParameterFilter {
                $key -eq 'newPrincipal' -and
                $cacheType -eq 'LiveGroups'
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -Exactly -ParameterFilter {
                $key -eq 'localPrincipal' -and
                $type -eq 'Group'
            }

            Assert-MockCalled -CommandName Add-CacheItem -Times 1 -Exactly -ParameterFilter {
                $key -eq 'newPrincipal' -and
                $type -eq 'Group'
            }

            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -Exactly -ParameterFilter {
                $cacheType -eq 'Group'
            }
        }
    }

    Context 'When LookupResult has no local cache' {
        It 'Should not call Remove-CacheItem' {
            $LookupResult = @{
                Status = [DSCGetSummaryState]::Existing
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
                localCache = $null
            }

            $Global:DSCAZDO_OrganizationName = 'TestOrg'

            $result = Set-AzDoProjectGroup -GroupName 'TestGroup' -GroupDescription 'TestDescription' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-CacheItem -Times 0 -Exactly
        }
    }
}
