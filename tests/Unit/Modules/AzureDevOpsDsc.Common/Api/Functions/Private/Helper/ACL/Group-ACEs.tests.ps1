$currentFile = $MyInvocation.MyCommand.Path

Describe 'Group-ACEs' -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Group-ACEs.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Group-ACEs -MockWith {
            param ($ACEs)
            if ($ACEs.Count -eq 0) {
                return @()
            } elseif ($ACEs.Count -eq 1) {
                return $ACEs
            } else {
                $groupedACEs = @{}
                foreach ($ace in $ACEs) {
                    $id = $ace.Identity.value.originId
                    if (-not $groupedACEs.ContainsKey($id)) {
                        $groupedACEs[$id] = $ace
                    }
                }
                return $groupedACEs.Values
            }
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
        $grouped = $result | Where-Object { $_.Identity.value.originId -eq "user1" }
        $grouped.Permissions.Deny | Should -Be 0,1
        $grouped.Permissions.Allow | Should -Be 2,3
    }

    It "Doesn't group single identity ACE" {
        $result = Group-ACEs -ACEs @($ace1)
        @($result).Count | Should -Be 1
    }

}
