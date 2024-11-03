$currentFile = $MyInvocation.MyCommand.Path

Describe 'Remove-AzDoProjectGroup' {

    AfterAll {
        # Clean up
        Remove-Variable -Name DSCAZDO_OrganizationName -ErrorAction SilentlyContinue
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-AzDoProjectGroup.tests.ps1'
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

        $mockProjectName = "TestProject"
        $mockGroupName = "TestGroup"
        $mockDescription = "TestDescription"

        # Mocking external functions that are called within the function
        Mock -CommandName Remove-DevOpsGroup -Verifiable
        Mock -CommandName Remove-CacheItem -Verifiable
        Mock -CommandName Set-CacheObject -Verifiable

    }

    Context 'When LookupResult has no cache items' {
        It 'Should return without calling any other functions' {
            $LookupResult = @{
                liveCache = $null
                localCache = $null
            }

            $result = Remove-AzDoProjectGroup -GroupName 'TestGroup' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 0 -Exactly
            Assert-MockCalled -CommandName Remove-CacheItem -Times 0 -Exactly
            Assert-MockCalled -CommandName Set-CacheObject -Times 0 -Exactly
        }
    }

    Context 'When LookupResult has liveCache but no localCache' {

        It 'Should call Remove-DevOpsGroup and remove cache items' {
            $LookupResult = @{
                liveCache = @{
                    Descriptor = 'liveDescriptor'
                    principalName = 'livePrincipal'
                }
                localCache = $null
            }

            $result = Remove-AzDoProjectGroup -GroupName 'TestGroup' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 1 -Exactly
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -ParameterFilter { $type -eq 'LiveGroups' }
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -Exactly -ParameterFilter { $cacheType -eq 'LiveGroups' }
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -Exactly -ParameterFilter { $type -eq 'Group' }
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -Exactly -ParameterFilter { $cacheType -eq 'Group' }
        }
    }

    Context 'When LookupResult has both liveCache and localCache' {
        It 'Should use liveCache descriptor and principal name' {
            $LookupResult = @{
                liveCache = @{
                    Descriptor = 'liveDescriptor'
                    principalName = 'livePrincipal'
                }
                localCache = @{
                    Descriptor = 'localDescriptor'
                    principalName = 'localPrincipal'
                }
            }

            $result = Remove-AzDoProjectGroup -GroupName 'TestGroup' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 1
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -ParameterFilter { $type -eq 'LiveGroups' }
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -ParameterFilter { $cacheType -eq 'LiveGroups' }
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -ParameterFilter { $type -eq 'Group' }
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -ParameterFilter { $cacheType -eq 'Group' }
        }
    }

    Context 'When only localCache exists' {
        It 'Should use localCache descriptor and principal name' {
            $LookupResult = @{
                liveCache = $null
                localCache = @{
                    Descriptor = 'localDescriptor'
                    principalName = 'localPrincipal'
                }
            }

            $result = Remove-AzDoProjectGroup -GroupName 'TestGroup' -ProjectName 'TestProject' -LookupResult $LookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 1
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -ParameterFilter { $type -eq 'LiveGroups' }
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -ParameterFilter { $cacheType -eq 'LiveGroups' }
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -ParameterFilter { $type -eq 'Group' }
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -ParameterFilter { $cacheType -eq 'Group' }
        }
    }
}
