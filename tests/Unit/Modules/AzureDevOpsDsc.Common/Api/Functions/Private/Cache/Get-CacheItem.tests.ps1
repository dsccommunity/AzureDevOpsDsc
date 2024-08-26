$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-CacheItem' -Tags "Unit", "Cache" {
    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @('Type1', 'Type2') }
        Mock -CommandName Get-CacheObject

    }

    Context 'Valid Cache Item' {
        It 'Returns cache item value' {
            $expectedValue = 'TestValue'

            Mock -CommandName Get-CacheObject -MockWith {

                $list = [System.Collections.Generic.List[CacheItem]]::New()
                $listItem = [CacheItem]::New('MyKey', $expectedValue)
                $list.Add($listItem)

                return $list
            }

            $result = Get-CacheItem -Key 'MyKey' -Type 'Type1'
            $result | Should -Be $expectedValue
        }
    }

    Context 'Cache item does not exist' {
        It 'Returns $null when cache item is not found' {
            Mock -CommandName Get-CacheObject -MockWith {

                $list = [System.Collections.Generic.List[CacheItem]]::New()
                $listItem = [CacheItem]::New('MyKey', $expectedValue)
                $list.Add($listItem)

                return $list
            }

            $result = Get-CacheItem -Key 'NonExistentKey' -Type 'Type1'
            $result | Should -Be $null
        }
    }

    Context 'Error handling' {
        It 'Logs error to verbose stream and returns $null' {
            Mock -CommandName Write-Verbose
            Mock -CommandName Get-CacheObject -MockWith { throw 'Test exception' }

            $result = { Get-CacheItem -Key 'MyKey' -Type 'Type1' } | Should -Not -Throw
            $result | Should -Be $null

            Assert-MockCalled -CommandName Write-Verbose -Exactly 1
        }
    }

    Context 'Using Filter' {
        It 'Applies provided filter to cache items' {
            $filteredValue = 'FilteredValue'

            Mock -CommandName Get-CacheObject -MockWith {
                $list = [System.Collections.Generic.List[CacheItem]]::New()
                $list.Add([CacheItem]::New('OtherKey', 'OtherValue'))
                $list.Add([CacheItem]::New('MyKey', $filteredValue))
                return $list
            }

            $result = Get-CacheItem -Key 'MyKey' -Type 'Type1' -Filter { $_.Value -eq $filteredValue }
            $result | Should -Be $filteredValue
        }
    }
}
