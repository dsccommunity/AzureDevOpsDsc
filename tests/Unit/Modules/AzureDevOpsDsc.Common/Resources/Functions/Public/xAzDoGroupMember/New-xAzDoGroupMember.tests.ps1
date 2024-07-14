powershell
Describe "New-xAzDoGroupMember" {

    Mock -ModuleName 'AzDoModule' -CommandName 'Find-AzDoIdentity' {
        param ($Identity)
        return [PSCustomObject]@{ displayName = $Identity; originId = [guid]::NewGuid().ToString() }
    }

    Mock -ModuleName 'AzDoModule' -CommandName 'Get-CacheObject' {
        param ($CacheType)
        return @()
    }

    Mock -ModuleName 'AzDoModule' -CommandName 'New-DevOpsGroupMember' {
        param ($params, $MemberIdentity)
        return $MemberIdentity
    }

    Mock -ModuleName 'AzDoModule' -CommandName 'Add-CacheItem' {}

    Mock -ModuleName 'AzDoModule' -CommandName 'Set-CacheObject' {}

    $global:DSCAZDO_OrganizationName = 'testOrg'
    $global:AzDoLiveGroupMembers = @{}

    Context "When valid parameters are passed" {
        It "Should call Find-AzDoIdentity for the group name" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-xAzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -ModuleName 'AzDoModule' -CommandName 'Find-AzDoIdentity' -Times 1 -Exactly -Scope It
        }

        It "Should add members to the group" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-xAzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -ModuleName 'AzDoModule' -CommandName 'New-DevOpsGroupMember' -Times 2 -Exactly -Scope It
        }

        It "Should cache group members" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            New-xAzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers

            Assert-MockCalled -ModuleName 'AzDoModule' -CommandName 'Add-CacheItem' -Times 1 -Exactly -Scope It
            Assert-MockCalled -ModuleName 'AzDoModule' -CommandName 'Set-CacheObject' -Times 1 -Exactly -Scope It
        }
    }

    Context "When no members are found" {
        Mock -ModuleName 'AzDoModule' -CommandName 'Find-AzDoIdentity' {
            param ($Identity)
            return $null
        }

        It "Should write a warning when no members are found" {
            $GroupName = 'TestGroup'
            $GroupMembers = @('User1', 'User2')

            { New-xAzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers } | Should -Throw -ErrorId 'PSScriptCmdlet:WriteWarning'
        }
    }
}

