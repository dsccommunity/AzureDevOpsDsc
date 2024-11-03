$currentFile = $MyInvocation.MyCommand.Path

Describe 'Group-ACEs' -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Group-ACEs.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        $ace1 = @{
            Identity = @{
                value = @{
                    originId = "user1"
                }
            }
            Permissions = @{
                Deny = 0, 1
                Allow = 2, 3
                DescriptorType = "SecurityNamespace"
            }
        }

        $ace2 = @{
            Identity = @{
                value = @{
                    originId = "user1"
                }
            }
            Permissions = @{
                Deny = 0, 1
                Allow = 2, 3
                DescriptorType = "SecurityNamespace"
            }
        }

        $ace3 = @{
            Identity = @{
                value = @{
                    originId = "user2"
                }
            }
            Permissions = @{
                Deny = 0, 1
                Allow = 2, 3
                DescriptorType = "SecurityNamespace"
            }
        }

    }

    It 'Returns empty list when ACEs are not provided' {
        $result = Group-ACEs -ACEs @()
        $result | Should -BeNullOrEmpty
    }

    It 'Processes single identity ACE' {
        $result = Group-ACEs -ACEs @($ace1)
        $result.Identity.value.originId | Should -Be "user1"
        $result.Permissions.Deny | Should -Be 0,1
        $result.Permissions.Allow | Should -Be 2,3
    }

    It 'Groups multiple identities correctly' {

        $result = Group-ACEs -ACEs @($ace1, $ace2, $ace3)
        $result.Count | Should -Be 2
        $user1 = $result | Where-Object { $_.Identity.value.originId -eq "user1" }
        $user2 = $result | Where-Object { $_.Identity.value.originId -eq "user2" }

        $user1.Permissions.Deny | Should -Be 0
        $user1.Permissions.Allow | Should -Be 2
        $user2.Permissions.Deny | Should -Be 0,1
        $user2.Permissions.Allow | Should -Be 2,3

    }

    It "Doesn't group single identity ACE" {
        $result = Group-ACEs -ACEs @($ace1)
        @($result).Count | Should -Be 1
    }

}
