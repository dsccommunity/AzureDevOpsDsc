$currentFile = $MyInvocation.MyCommand.Path

Describe 'Refresh-CacheIdentity' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Refresh-CacheObject.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('TypeA', 'TypeB', 'TypeC') }
        Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
            return [PSCustomObject]@{
                id = 'id123'
                descriptor = 'descriptor123'
                subjectDescriptor = 'subjectDescriptor123'
                providerDisplayName = 'providerDisplayName123'
                isActive = $true
                isContainer = $false
            }
        }
        Mock -CommandName Add-CacheItem -MockWith {}
        Mock -CommandName Get-CacheObject -MockWith { return @() }
        Mock -CommandName Set-CacheObject -MockWith {}

        $global:DSCAZDO_OrganizationName = 'TestOrg'
        $key = 'testKey'
        $cacheType = 'TypeA'

    }

    BeforeEach {
        $identity = [PSCustomObject]@{ descriptor = 'descriptor123' }
    }

    It 'Adds ACLIdentity to Identity' {

        Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

        $identity.PSObject.Properties.Match('ACLIdentity').Count | Should -Be 1
        $identity.ACLIdentity.id | Should -Be 'id123'
    }

    It 'Should not throw an error' {
        $ErrorActionPreference = 'Stop'
        { Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType } | Should -Not -Throw
    }

    It 'Should not throw an error when there are duplicate cache objects' {
        $ErrorActionPreference = 'Stop'
        { Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType } | Should -Not -Throw
        { Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType } | Should -Not -Throw
    }


    It 'Calls Add-CacheItem with correct parameters' {
        Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

        Assert-MockCalled -CommandName Add-CacheItem -Exactly 1
    }

    It 'Calls Set-CacheObject with current cache' {
        Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

        Assert-MockCalled -CommandName Set-CacheObject -Exactly 1 -Scope It
    }
}
