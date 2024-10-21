$currentFile = $MyInvocation.MyCommand.Path

Describe "New-AzDoGroupMember" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AzDoLiveGroupMembers -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
        $global:AzDoLiveGroupMembers = @{}

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-AzDoGroupMember.tests.ps1'
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
            param ($Identity)
            return [PSCustomObject]@{
                displayName = $Identity
                originId = [guid]::NewGuid().ToString()
                principalName = 'mockPrincipalName'
            }
        }

        Mock -CommandName Get-CacheObject -MockWith {
            param ($CacheType)
            return @()
        }

        Mock -CommandName New-DevOpsGroupMember -MockWith {
            param ($params, $MemberIdentity)
            return $MemberIdentity
        }

        Mock -CommandName Add-CacheItem
        Mock -CommandName Set-CacheObject

    }

    Context "When valid parameters are passed" {

        It "Should call Find-AzDoIdentity for the group name" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -CommandName Find-AzDoIdentity -Times 3 -Exactly -Scope It
        }

        It "Should add members to the group" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -CommandName New-DevOpsGroupMember -Times 2 -Exactly -Scope It
        }

        It "Should cache group members" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -CommandName Add-CacheItem -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-CacheObject -Times 1 -Exactly -Scope It
        }
    }

    Context "When no members are found" {

        BeforeAll {
            Mock -CommandName 'Find-AzDoIdentity' -MockWith {
                param ($Identity)
                return $null
            }
        }

        It "Should write an error when no identities are found" {
            Mock -CommandName Write-Warning
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            $result = New-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers
            Assert-MockCalled -Times 1 -ParameterFilter { $Message -like "*Unable to find identity for member*" } -CommandName Write-Warning
        }

        It "Should write a warning when no members are found" {
            Mock -CommandName Write-Warning
            Mock -CommandName Find-AzDoIdentity -ParameterFilter { ($Identity -eq 'User1') -or ($Identity -eq 'User2') }
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -CommandName 'Write-Warning' -ParameterFilter { $Message -like "*No group members found*" }

        }
    }
}
