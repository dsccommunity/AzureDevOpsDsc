powershell
Describe 'Test-xAzDoGroupMember' {
    
    $GroupName = "TestGroup"
    $GroupMembers = @('User1', 'User2')
    $LookupResult = @{ User1 = 'ID1'; User2 = 'ID2' }
    $Ensure = 'Present'
    $Force = $true

    It 'Should accept mandatory GroupName parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName } | Should -Not -Throw
    }

    It 'Should accept optional GroupMembers parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers } | Should -Not -Throw
    }

    It 'Should accept optional LookupResult parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName -LookupResult $LookupResult } | Should -Not -Throw
    }

    It 'Should accept optional Ensure parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName -Ensure $Ensure } | Should -Not -Throw
    }

    It 'Should accept Force switch parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName -Force } | Should -Not -Throw
        { Test-xAzDoGroupMember -GroupName $GroupName -Force:$false } | Should -Not -Throw
    }

    It 'Should fail without mandatory GroupName parameter' {
        { Test-xAzDoGroupMember } | Should -Throw
    }

    It 'Should handle null or empty GroupMembers parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName -GroupMembers $null } | Should -Not -Throw
        { Test-xAzDoGroupMember -GroupName $GroupName -GroupMembers @() } | Should -Not -Throw
    }

    It 'Should handle null or empty LookupResult parameter' {
        { Test-xAzDoGroupMember -GroupName $GroupName -LookupResult $null } | Should -Not -Throw
        { Test-xAzDoGroupMember -GroupName $GroupName -LookupResult @{} } | Should -Not -Throw
    }

    It 'Should return the expected result' {
        $result = Test-xAzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers -LookupResult $LookupResult -Ensure $Ensure -Force
        $result | Should -Be $return
    }

}

