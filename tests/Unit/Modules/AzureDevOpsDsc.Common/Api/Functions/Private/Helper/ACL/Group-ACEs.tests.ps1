Describe 'Group-ACEs' {

    BeforeAll {
        function Mock-ACE {
            param (
                [string] $originId,
                [string] $Identity,
                [int[]] $Deny,
                [int[]] $Allow,
                [string] $DescriptorType
            )
            return [PSCustomObject] @{
                Identity = [PSCustomObject]@{
                    value = [PSCustomObject]@{ originId = $originId }
                    Name = $Identity
                }
                Permissions = [PSCustomObject]@{
                    Deny           = $Deny
                    Allow          = $Allow
                    DescriptorType = $DescriptorType
                }
            }
        }

        $ace1 = Mock-ACE -originId "user1" -Identity "User One" -Deny 0,1 -Allow 2,3 -DescriptorType "Type1"
        $ace2 = Mock-ACE -originId "user2" -Identity "User Two" -Deny 1 -Allow 3 -DescriptorType "Type1"
        $ace3 = Mock-ACE -originId "user1" -Identity "User One" -Deny 0,1 -Allow 2,3 -DescriptorType "Type1"
    }

    It 'Returns empty list when ACEs are not provided' {
        $result = Group-ACEs -ACEs @()
        $result | Should -BeNullOrEmpty
    }

    It 'Processes single identity ACE' {
        $result = Group-ACEs -ACEs @($ace1)
        $result.Count | Should -Be 1
        $result[0].Identity.value.originId | Should -Be "user1"
        $result[0].Permissions.Deny | Should -Be 0,1
        $result[0].Permissions.Allow | Should -Be 2,3
    }

    It 'Groups multiple identities correctly' {
        $result = Group-ACEs -ACEs @($ace1, $ace2, $ace3)
        $result.Count | Should -Be 2
        $grouped = $result | Where-Object { $_.Identity.value.originId -eq "user1" }
        $grouped.Count | Should -Be 1
        $grouped[0].Permissions.Deny | Should -Be 0,1
        $grouped[0].Permissions.Allow | Should -Be 2,3
    }
}


