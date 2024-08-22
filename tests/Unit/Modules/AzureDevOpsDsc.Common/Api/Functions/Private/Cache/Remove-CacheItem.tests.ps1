$currentFile = $MyInvocation.MyCommand.Path

Describe 'Remove-CacheItem' {

    BeforeEach {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        Mock -CommandName Get-CacheObject -MockWith {
            param ([string]$CacheType)

            $list = [System.Collections.Generic.List[CacheItem]]::New()

            switch ($CacheType)
            {
                "Project"   {
                    $list.Add([CacheItem]::New("myKey", "someValue"))
                }
                "Group"     {
                    $list.Add([CacheItem]::New("anotherKey", "anotherValue"))
                }
                default     {
                    throw "Invalid CacheType"
                }
            }

            return $list

        }

        Mock -CommandName Set-Variable -MockWith {}

    }

    It 'Removes item from Project cache when key matches' {
        $cache = Get-CacheObject -CacheType "Project"
        Remove-CacheItem -Key "myKey" -Type "Project"
        $global:AzDoProject | Should -BeNullOrEmpty
    }

    It 'Removes item from Group cache when key matches' {
        $cache = Get-CacheObject -CacheType "Group"
        Remove-CacheItem -Key "anotherKey" -Type "Group"
        $global:AzDoGroup | Should -BeNullOrEmpty
    }

    It 'Handles non-matching key correctly' {
        $cache = Get-CacheObject -CacheType "Group"
        Remove-CacheItem -Key "nonMatchingKey" -Type "Group"
        $global:AzDoGroup | Should -Be $null
    }

    It 'Validates Type parameter against cache objects' {
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Project', 'Group', 'Team', 'SecurityDescriptor') }
        { Remove-CacheItem -Key "sampleKey" -Type "InvalidType" } | Should -Throw
    }

}
