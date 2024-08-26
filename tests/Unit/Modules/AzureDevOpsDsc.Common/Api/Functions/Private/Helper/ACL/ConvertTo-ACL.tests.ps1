$currentFile = $MyInvocation.MyCommand.Path

Describe "ConvertTo-ACL" -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-ACL.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Write-Warning
        Mock -CommandName New-ACLToken -MockWith { return @{ Token = "mockToken" } }
        Mock -CommandName ConvertTo-ACEList -MockWith {
            return @(
                @{ Identity = "User1"; Permissions = "Read" },
                @{ Identity = "User2"; Permissions = "Read, Write" }
            )
        }
        Mock -CommandName Group-ACEs -MockWith { param($ACEs) return $ACEs }

        $permissions = @(
            @{
                Identity    = 'User1'
                Permissions = 'Read'
            },
            @{
                Identity    = 'User2'
                Permissions = 'Read', 'Write'
            }
        )

    }

    It "should return an ACL with correct properties" {
        $result = ConvertTo-ACL -Permissions $permissions -SecurityNamespace 'Namespace1' -isInherited $true -OrganizationName 'Org1' -TokenName 'Token1'

        $result | Should -Not -BeNullOrEmpty
        $result.token.Token | Should -Be "mockToken"
        $result.aces | Should -HaveCount 2
        $result.inherited | Should -Be $true
    }

    It "should return a warning if no ACEs are created" {
        Mock -CommandName ConvertTo-ACEList -MockWith { return @() }
        $result = ConvertTo-ACL -Permissions $permissions -SecurityNamespace 'Namespace1' -isInherited $true -OrganizationName 'Org1' -TokenName 'Token1'
        $result.aces | Should -HaveCount 0
    }
}

# End of Pester tests for ConvertTo-ACL
