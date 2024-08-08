Describe 'Format-AzDoGroup' {
    BeforeAll {
        Import-Module .\path\to\your\module.psm1 # Adjust the path to where your function is located
    }

    Context 'Formatting UPN' {
        It 'Should format correctly with valid inputs' {
            $result = Format-AzDoGroup -Prefix "Contoso" -GroupName "Developers"
            $result | Should -Be "[Contoso]\Developers"
        }

        It 'Should remove starting/ending square brackets from Prefix' {
            $result = Format-AzDoGroup -Prefix "[Contoso]" -GroupName "Developers"
            $result | Should -Be "[Contoso]\Developers"
        }

        It 'Should handle empty prefix' {
            $result = Format-AzDoGroup -Prefix "" -GroupName "Developers"
            $result | Should -Be "[]\Developers"
        }

        It 'Should handle empty group name' {
            $result = Format-AzDoGroup -Prefix "Contoso" -GroupName ""
            $result | Should -Be "[Contoso]\"
        }

        It 'Should throw error for missing parameters' {
            { Format-AzDoGroup -GroupName "Developers" } | Should -Throw
            { Format-AzDoGroup -Prefix "Contoso" } | Should -Throw
        }
    }
}

