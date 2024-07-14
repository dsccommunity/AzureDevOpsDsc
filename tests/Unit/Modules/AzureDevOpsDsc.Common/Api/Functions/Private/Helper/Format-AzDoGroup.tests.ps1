powershell
Describe 'Format-AzDoGroup' {
    It 'Should format with valid Prefix and GroupName' {
        $result = Format-AzDoGroup -Prefix "Contoso" -GroupName "Developers"
        $result | Should -Be "[Contoso]\Developers"
    }

    It 'Should remove starting and ending square brackets from Prefix' {
        $result = Format-AzDoGroup -Prefix "[Contoso]" -GroupName "Developers"
        $result | Should -Be "[Contoso]\Developers"
    }

    It 'Should handle Prefix without brackets' {
        $result = Format-AzDoGroup -Prefix "AnotherCompany" -GroupName "Admins"
        $result | Should -Be "[AnotherCompany]\Admins"
    }

    It 'Should handle GroupName with spaces' {
        $result = Format-AzDoGroup -Prefix "OrgName" -GroupName "Super Users"
        $result | Should -Be "[OrgName]\Super Users"
    }

    It 'Should handle empty Prefix' {
        { Format-AzDoGroup -Prefix "" -GroupName "EmptyPrefixGroup" } | Should -Throw
    }

    It 'Should handle empty GroupName' {
        { Format-AzDoGroup -Prefix "EmptyGroupName" -GroupName "" } | Should -Throw
    }

    It 'Should be verbose when Verbose is enabled' {
        $result = { Format-AzDoGroup -Prefix "VerboseTest" -GroupName "Check" -Verbose }
        $result | Should -Contain "[Format-AzDoGroup] Formatting User Principal Name with Prefix: 'VerboseTest' and GroupName: 'Check'."
        $result | Should -Contain "[Format-AzDoGroup] Resulting User Principal Name: '[VerboseTest]\Check'."
    }
}

