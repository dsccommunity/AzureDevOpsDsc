$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-AzDoOrganizationGroup' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AzDoGroup -Scope Global
    }

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzDoOrganizationGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')

        # Mock the external functions used within Set-AzDoOrganizationGroup
        Mock -CommandName Set-DevOpsGroup -MockWith {
            return @{
                principalName = 'testPrincipalName'
                descriptor = 'testDescriptor'
            }
        }

        Mock -CommandName Refresh-CacheIdentity
        Mock -CommandName Remove-CacheItem
        Mock -CommandName Add-CacheItem
        Mock -CommandName Set-CacheObject
        Mock -CommandName Write-Warning

    }
    BeforeEach {
        # Reset global variables before each test
        $Global:DSCAZDO_OrganizationName = "TestOrg"
        $Global:AzDoGroup = @{}
    }

    Context 'When group has been renamed' {
        It 'Should write a warning and return without setting the group' {
            $lookupResult = @{
                Status = [DSCGetSummaryState]::Renamed
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
                localCache = @{
                    principalName = 'localPrincipalName'
                }
            }

            $result = Set-AzDoOrganizationGroup -GroupName 'TestGroup' -LookupResult $lookupResult

            $result | Should -BeNullOrEmpty
            Assert-MockCalled -CommandName Set-DevOpsGroup -Times 0 -Scope It
            Assert-MockCalled -CommandName Refresh-CacheIdentity -Times 0 -Scope It
            Assert-MockCalled -CommandName Remove-CacheItem -Times 0 -Scope It
            Assert-MockCalled -CommandName Add-CacheItem -Times 0 -Scope It
            Assert-MockCalled -CommandName Set-CacheObject -Times 0 -Scope It
        }
    }

    Context 'When group needs to be set' {
        It 'Should set the group and update the caches' {
            $lookupResult = @{
                Status = [DSCGetSummaryState]::None
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
                localCache = @{
                    principalName = 'localPrincipalName'
                }
            }

            $result = Set-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Description' -LookupResult $lookupResult

            $result | Should -Not -BeNullOrEmpty
            $result.principalName | Should -Be 'testPrincipalName'

            Assert-MockCalled -CommandName Set-DevOpsGroup -Exactly -Times 1 -ParameterFilter {
                $ApiUri -eq 'https://vssps.dev.azure.com/TestOrg' -and
                $GroupName -eq 'TestGroup' -and
                $GroupDescription -eq 'Test Description' -and
                $GroupDescriptor -eq 'liveDescriptor'
            }

            Assert-MockCalled -CommandName Refresh-CacheIdentity -Exactly -Times 1 -ParameterFilter {
                $Identity.principalName -eq 'testPrincipalName' -and
                $CacheType -eq 'LiveGroups'
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Exactly -Times 1 -ParameterFilter {
                $Key -eq 'localPrincipalName' -and
                $Type -eq 'Group'
            }

            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 1 -ParameterFilter {
                $Key -eq 'testPrincipalName' -and
                $Type -eq 'Group'
            }

            Assert-MockCalled -CommandName Set-CacheObject -Exactly -Times 1 -ParameterFilter {
                $CacheType -eq 'Group'
            }
        }
    }

    Context 'When there is no local cache' {
        It 'Should set the group and update the caches without removing any cache item' {
            $lookupResult = @{
                Status = [DSCGetSummaryState]::None
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
                localCache = $null
            }

            $result = Set-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Description' -LookupResult $lookupResult

            $result | Should -Not -BeNullOrEmpty
            $result.principalName | Should -Be 'testPrincipalName'

            Assert-MockCalled -CommandName Set-DevOpsGroup -Exactly -Times 1 -ParameterFilter {
                $ApiUri -eq 'https://vssps.dev.azure.com/TestOrg' -and
                $GroupName -eq 'TestGroup' -and
                $GroupDescription -eq 'Test Description' -and
                $GroupDescriptor -eq 'liveDescriptor'
            }

            Assert-MockCalled -CommandName Refresh-CacheIdentity -Exactly -Times 1 -ParameterFilter {
                $Identity.principalName -eq 'testPrincipalName' -and
                $CacheType -eq 'LiveGroups'
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Times 0 -Scope It
            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 1 -ParameterFilter {
                $Key -eq 'testPrincipalName' -and
                $Type -eq 'Group'
            }

            Assert-MockCalled -CommandName Set-CacheObject -Exactly -Times 1 -ParameterFilter {
                $CacheType -eq 'Group'
            }
        }
    }

    Context 'When an exception occurs while setting the group' {

        It 'Should throw the exception' {

            Mock -CommandName Set-DevOpsGroup -MockWith {
                throw 'An error occurred'
            }

            $lookupResult = @{
                Status = [DSCGetSummaryState]::None
                liveCache = @{
                    descriptor = 'liveDescriptor'
                }
                localCache = $null
            }

            { Set-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Description' -LookupResult $lookupResult } | Should -Throw 'An error occurred'
        }
    }
}
