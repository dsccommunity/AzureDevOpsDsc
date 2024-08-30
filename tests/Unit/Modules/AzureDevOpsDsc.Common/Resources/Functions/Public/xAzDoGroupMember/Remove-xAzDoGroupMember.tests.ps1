$currentFile = $MyInvocation.MyCommand.Path

Describe 'Remove-xAzDoGroupMember Tests' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AzDoLiveGroupMembers -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
        $global:AzDoLiveGroupMembers = @{}

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-xAzDoGroupMember.tests.ps1'
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

        Mock -CommandName Find-AzDoIdentity -MockWith {
            return @{ principalName = 'mockUser@domain.com' }
        }

        Mock -CommandName Get-CacheItem -MockWith {
            return @(
                @{ principalName = 'userA@domain.com' },
                @{ principalName = 'userB@domain.com' }
            )
        }

        Mock -CommandName Remove-DevOpsGroupMember -MockWith {
            return @{ Result = 'Success' }
        }

        Mock -CommandName Write-Warning
        Mock -CommandName Remove-CacheItem
        Mock -CommandName Set-CacheObject
        Mock -CommandName Format-AzDoProjectName -MockWith { return '[TestProjectName]\GroupName' }

    }

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'MockOrganization'
        $Global:AzDoLiveGroupMembers = 'MockMembers'
    }

    Context "when functioning correctly" {
        It 'Should remove group members correctly' {
            $GroupName = 'TestGroup'
            $result = Remove-xAzDoGroupMember -GroupName $GroupName

            Assert-MockCalled -CommandName Find-AzDoIdentity -Times 1
            Assert-MockCalled -CommandName Get-CacheItem -Times 1
            Assert-MockCalled -CommandName Remove-DevOpsGroupMember -Times 2

        }

        It 'Should update the cache' {
            Mock -CommandName Write-Warning

            $GroupName = 'TestGroup'
            $result = Remove-xAzDoGroupMember -GroupName $GroupName

            Assert-MockCalled -CommandName Write-Warning -ParameterFilter { $Message -like '*No group members found*'} -Exactly 0
            Assert-MockCalled -CommandName Remove-CacheItem -Times 1
            Assert-MockCalled -CommandName Set-CacheObject -Times 1

        }

        It 'Should handle an empty members list' {
            Mock -CommandName Get-CacheItem -MockWith {
                return @()
            }
            Mock -CommandName Write-Warning

            $GroupName = 'TestGroup'
            $result = Remove-xAzDoGroupMember -GroupName $GroupName

            Assert-MockCalled -CommandName Find-AzDoIdentity -Exactly 1
            Assert-MockCalled -CommandName Remove-DevOpsGroupMember -Exactly 0
            Assert-MockCalled -CommandName Remove-CacheItem -Exactly 1
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 1

        }

        It 'Should handle a bad members list' {

            $GroupName = 'TestGroup'

            Mock -CommandName Find-AzDoIdentity -MockWith {
                return @(' ', $null)
            } -ParameterFilter { $Identity -ne $GroupName }

            Mock -CommandName Write-Warning

            $result = Remove-xAzDoGroupMember -GroupName $GroupName

            Assert-MockCalled -CommandName Write-Warning -ParameterFilter { $Message -like '*Unable to find identity*'} -Exactly 2
            Assert-MockCalled -CommandName Remove-DevOpsGroupMember -Exactly 0
            Assert-MockCalled -CommandName Remove-CacheItem -Exactly 1
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 1
        }

    }

    Context "when failing" {

        It 'Should handle a missing group identity' {
            Mock -CommandName Find-AzDoIdentity -MockWith {
                return $null
            }

            Mock -CommandName Write-Warning

            $GroupName = 'TestGroup'
            $result = Remove-xAzDoGroupMember -GroupName $GroupName

            Assert-MockCalled -CommandName Write-Warning -ParameterFilter { $Message -like '*Unable to find identity*'} -Exactly 1
            Assert-MockCalled -CommandName Remove-DevOpsGroupMember -Exactly 0
            Assert-MockCalled -CommandName Remove-CacheItem -Exactly 0
            Assert-MockCalled -CommandName Set-CacheObject -Exactly 0
        }

    }


}
