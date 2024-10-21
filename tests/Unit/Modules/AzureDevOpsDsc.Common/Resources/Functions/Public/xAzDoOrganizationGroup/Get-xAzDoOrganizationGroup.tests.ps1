$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-AzDoOrganizationGroup' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzDoOrganizationGroup.tests.ps1'
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

        Mock -CommandName Format-AzDoGroup -MockWith { return "[$Global:DSCAZDO_OrganizationName]_$GroupName" }
        Mock -CommandName Get-CacheItem -MockWith {
            switch($Type) {
                'LiveGroups' {
                    return @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
                }
                'Group' {
                    return @{ originId = '123'; description = 'Test Group'; name = 'TestGroup'}
                }
            }
        }

    }

    Context 'When group is present in live cache and local cache with same originId' -skip {
        BeforeAll {
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'LiveGroups' } -MockWith {
                return @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Key -eq 'Group' } -MockWith {
                return @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
        }

        It 'should return unchanged status if properties match' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'Unchanged'
            $result.Ensure | Should -Be 'Present'
        }

        It 'should return changed status if properties differ' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'New Description'
            $result.status | Should -Be 'Changed'
            $result.propertiesChanged | Should -Contain 'Description'
        }
    }

    Context 'When group is renamed' {
        BeforeAll {
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'LiveGroups' } -MockWith {
                return @{ originId = '123'; description = 'Test Group'; name = 'NewTestGroup' }
            }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'Group' } -MockWith {
                return @{ originId = '123'; description = 'Test Group'; name = 'OldTestGroup' }
            }
        }

        It 'should detect renamed group' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'Changed'
            $result.propertiesChanged[0] | Should -Be 'Name'
        }
    }

    Context 'When group is missing in live cache but present in local cache' {
        BeforeAll {
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'LiveGroups' } -MockWith {
                return $null
            }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'Group' } -MockWith {
                return @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
        }

        It 'should return not found status' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'NotFound'
            $result.propertiesChanged | Should -Be @('description', 'displayName')
        }
    }

    Context 'When group is present in live cache but missing in local cache' {
        BeforeAll {
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'LiveGroups' } -MockWith {
                return @{ originId = '123'; description = 'Test Group'; name = 'TestGroup' }
            }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'Group' } -MockWith {
                return $null
            }
        }

        It 'should return changed' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'Changed'
        }

        It 'should return changed if properties differ' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'New Description'
            $result.status | Should -Be 'Changed'
            $result.propertiesChanged | Should -Contain 'description'
        }
    }

    Context 'When both live cache and local cache are missing the group' {
        BeforeAll {
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'LiveGroups' } -MockWith {
                return $null
            }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'Group' } -MockWith {
                return $null
            }
        }

        It 'should return not found status' {
            $result = Get-AzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Group'
            $result.status | Should -Be 'NotFound'
            $result.propertiesChanged | Should -Be @('description', 'displayName')
        }
    }
}
