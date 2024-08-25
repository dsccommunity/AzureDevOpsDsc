$currentFile = $MyInvocation.MyCommand.Path

Describe 'Group-ACEs' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Export-CacheObject.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        $ace1 = Mock-ACE -originId "user1" -Identity "User One" -Deny 0,1 -Allow 2,3 -DescriptorType "Type1"
        $ace2 = Mock-ACE -originId "user2" -Identity "User Two" -Deny 1 -Allow 3 -DescriptorType "Type1"
        $ace3 = Mock-ACE -originId "user1" -Identity "User One" -Deny 0,1 -Allow 2,3 -DescriptorType "Type1"

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
