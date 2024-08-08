Describe 'New-ACLToken Function Tests' {

    BeforeAll {
        Import-Module -Name 'AzureDevOpsDsc.Common' -Force
    }

    Mock -CommandName Get-CacheItem {
        return [PSCustomObject]@{id = "1234"}
    }

    Context 'Git Repositories Namespace' {

        It 'Should return GitOrganization type for valid Git organization token' {
            $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName '[OrgName]'
            $result.type | Should -Be 'GitOrganization'
        }

        It 'Should return GitProject type for valid Git project token' {
            $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName '[OrgName]/[ProjectName]'
            $result.type | Should -Be 'GitProject'
            $result.projectId | Should -Be '1234'
        }

        It 'Should return GitRepository type for valid Git repository token' {
            $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName '[OrgName]/[ProjectName]/[RepoName]'
            $result.type | Should -Be 'GitRepository'
            $result.projectId | Should -Be '1234'
            $result.RepoId | Should -Be '1234'
        }

        It 'Should return GitUnknown type for unknown Git token' {
            $result = New-ACLToken -SecurityNamespace 'Git Repositories' -TokenName 'Unknown/Token'
            $result.type | Should -Be 'GitUnknown'
        }

    }

    Context 'Identity Namespace' {

        It 'Should return GitGroupPermission type for valid identity group token' {
            $result = New-ACLToken -SecurityNamespace 'Identity' -TokenName '[ProjectId]/[GroupId]'
            $result.type | Should -Be 'GitGroupPermission'
            $result.projectId | Should -Be 'ProjectId'
            $result.groupId | Should -Be 'GroupId'
        }

        It 'Should return GroupUnknown type for unknown identity token' {
            $result = New-ACLToken -SecurityNamespace 'Identity' -TokenName 'Unknown/Token'
            $result.type | Should -Be 'GroupUnknown'
        }
    }

    Context 'Unknown SecurityNamespace' {

        It 'Should return UnknownSecurityNamespace type for unrecognized security namespace' {
            $result = New-ACLToken -SecurityNamespace 'Unknown' -TokenName 'Any/Token'
            $result.type | Should -Be 'UnknownSecurityNamespace'
        }

    }

}

