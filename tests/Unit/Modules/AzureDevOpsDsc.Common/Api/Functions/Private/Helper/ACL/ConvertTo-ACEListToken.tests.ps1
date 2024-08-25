$currentFile = $MyInvocation.MyCommand.Path

Describe "ConvertTo-ACETokenList Tests" {

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

    }

    BeforeEach {
        # Mock Get-CacheItem to return a mock SecurityDescriptor
        Mock -CommandName Get-CacheItem -MockWith {
            return @{
                actions = @(
                    @{ displayName = "Read"; name = "read" },
                    @{ displayName = "Write"; name = "write" },
                    @{ displayName = "Execute"; name = "execute" }
                )
            }
        }
    }

    It "should return an empty list when SecurityDescriptor is not found" {
        # Mock to return $null for not found SecurityDescriptor
        Mock -CommandName Get-CacheItem -MockWith { return $null }

        $result = ConvertTo-ACETokenList -SecurityNamespace "TestNamespace" -ACEPermissions @(
            @{ "Read" = "Allow"; "Write" = "Deny" }
        )

        $result | Should -BeNullOrEmpty
    }

    It "should correctly process Allow and Deny permissions" {
        $acePermissions = @(
            @{ "Read" = "Allow"; "Write" = "Deny" },
            @{ "Execute" = "Allow"; "Read" = "Deny" }
        )
        $result = ConvertTo-ACETokenList -SecurityNamespace "TestNamespace" -ACEPermissions $acePermissions

        $result | Should -HaveCount 2
        $result[0].DescriptorType | Should -Be "TestNamespace"
        $result[0].Allow.displayName | Should -Contain "Read"
        $result[0].Deny.displayName | Should -Contain "Write"
        $result[1].Allow.displayName | Should -Contain "Execute"
        $result[1].Deny.displayName | Should -Contain "Read"
    }

    It "should filter out permissions not found in the SecurityDescriptor" {
        $acePermissions = @(
            @{ "UnknownPermission" = "Allow"; "Read" = "Deny" }
        )
        $result = ConvertTo-ACETokenList -SecurityNamespace "TestNamespace" -ACEPermissions $acePermissions

        $result | Should -HaveCount 1
        $result[0].Allow | Should -BeNullOrEmpty
        $result[0].Deny.displayName | Should -Contain "Read"
    }
}

# End of Pester tests for ConvertTo-ACETokenList
