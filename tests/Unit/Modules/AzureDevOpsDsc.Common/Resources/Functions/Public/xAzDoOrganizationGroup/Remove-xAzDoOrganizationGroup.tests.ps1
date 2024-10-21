$currentFile = $MyInvocation.MyCommand.Path

Describe 'Remove-AzDoOrganizationGroup' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AZDOLiveGroups -Scope Global
        Remove-Variable -Name AzDoGroup -Scope Global
    }

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-AzDoOrganizationGroup.tests.ps1'
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

        # Mock the external functions used within Remove-AzDoOrganizationGroup
        Mock -CommandName Remove-DevOpsGroup
        Mock -CommandName Remove-CacheItem
        Mock -CommandName Set-CacheObject

    }

    BeforeEach {
        # Reset global variables before each test
        $Global:DSCAZDO_OrganizationName = "TestOrg"
        $Global:AZDOLiveGroups = @{}
        $Global:AzDoGroup = @{}
    }

    Context 'When no cache items exist' {
        It 'Should return without performing any operations' {
            $lookupResult = @{
                liveCache = $null
                localCache = $null
            }

            Remove-AzDoOrganizationGroup -GroupName 'TestGroup' -LookupResult $lookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Times 0
            Assert-MockCalled -CommandName Remove-CacheItem -Times 0
            Assert-MockCalled -CommandName Set-CacheObject -Times 0
        }
    }

    Context 'When group is found in live cache' {
        It 'Should remove the group and update the caches' {
            $lookupResult = @{
                liveCache = @{
                    Descriptor = 'LiveDescriptor'
                    principalName = 'livePrincipalName'
                }
                localCache = $null
            }

            Remove-AzDoOrganizationGroup -GroupName 'TestGroup' -LookupResult $lookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Exactly -Times 1 -ParameterFilter {
                $GroupDescriptor -eq 'LiveDescriptor' -and
                $ApiUri -eq 'https://vssps.dev.azure.com/TestOrg'
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Exactly -Times 2
            Assert-MockCalled -CommandName Set-CacheObject -Exactly -Times 2
        }
    }

    Context 'When group is found in local cache but not in live cache' {
        It 'Should remove the group and update the caches' {
            $lookupResult = @{
                liveCache = $null
                localCache = @{
                    Descriptor = 'LocalDescriptor'
                    principalName = 'localPrincipalName'
                }
            }

            Remove-AzDoOrganizationGroup -GroupName 'TestGroup' -LookupResult $lookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Exactly -Times 1 -ParameterFilter {
                $GroupDescriptor -eq 'LocalDescriptor' -and
                $ApiUri -eq 'https://vssps.dev.azure.com/TestOrg'
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Exactly -Times 2
            Assert-MockCalled -CommandName Set-CacheObject -Exactly -Times 2
        }
    }

    Context 'When both live and local cache are present' {
        It 'Should prioritize live cache and remove the group' {
            $lookupResult = @{
                liveCache = @{
                    Descriptor = 'LiveDescriptor'
                    principalName = 'livePrincipalName'
                }
                localCache = @{
                    Descriptor = 'LocalDescriptor'
                    principalName = 'localPrincipalName'
                }
            }

            Remove-AzDoOrganizationGroup -GroupName 'TestGroup' -LookupResult $lookupResult

            Assert-MockCalled -CommandName Remove-DevOpsGroup -Exactly -Times 1 -ParameterFilter {
                $GroupDescriptor -eq 'LiveDescriptor' -and
                $ApiUri -eq 'https://vssps.dev.azure.com/TestOrg'
            }

            Assert-MockCalled -CommandName Remove-CacheItem -Exactly -Times 2
            Assert-MockCalled -CommandName Set-CacheObject -Exactly -Times 2
        }
    }
}
