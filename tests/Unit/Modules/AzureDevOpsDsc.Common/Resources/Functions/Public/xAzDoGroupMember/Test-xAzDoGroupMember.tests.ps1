$currentFile = $MyInvocation.MyCommand.Path

Describe 'Test-AzDoGroupMember' -skip {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AzDoLiveGroupMembers -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
        $global:AzDoLiveGroupMembers = @{}

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDoGroupMember.tests.ps1'
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

        $GroupName = "TestGroup"
        $GroupMembers = @('User1', 'User2')
        $LookupResult = @{ User1 = 'ID1'; User2 = 'ID2' }
        $Ensure = 'Present'
        $Force = $true

    }

    It 'Should accept mandatory GroupName parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName } | Should -Not -Throw
    }

    It 'Should accept optional GroupMembers parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers } | Should -Not -Throw
    }

    It 'Should accept optional LookupResult parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName -LookupResult $LookupResult } | Should -Not -Throw
    }

    It 'Should accept optional Ensure parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName -Ensure $Ensure } | Should -Not -Throw
    }

    It 'Should accept Force switch parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName -Force } | Should -Not -Throw
        { Test-AzDoGroupMember -GroupName $GroupName -Force:$false } | Should -Not -Throw
    }

    It 'Should fail without mandatory GroupName parameter' {
        { Test-AzDoGroupMember } | Should -Throw
    }

    It 'Should handle null or empty GroupMembers parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName -GroupMembers $null } | Should -Not -Throw
        { Test-AzDoGroupMember -GroupName $GroupName -GroupMembers @() } | Should -Not -Throw
    }

    It 'Should handle null or empty LookupResult parameter' {
        { Test-AzDoGroupMember -GroupName $GroupName -LookupResult $null } | Should -Not -Throw
        { Test-AzDoGroupMember -GroupName $GroupName -LookupResult @{} } | Should -Not -Throw
    }

    It 'Should return the expected result' {
        $result = Test-AzDoGroupMember -GroupName $GroupName -GroupMembers $GroupMembers -LookupResult $LookupResult -Ensure $Ensure -Force
        $result | Should -Be $return
    }
}
