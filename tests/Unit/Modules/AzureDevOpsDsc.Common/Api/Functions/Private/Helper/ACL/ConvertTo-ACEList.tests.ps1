$currentFile = $MyInvocation.MyCommand.Path

Describe "ConvertTo-ACEList" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-ACEList.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mock external functions
        Mock -CommandName Find-Identity -MockWith {
            return @{
                Identity = "MockIdentity"
            }
        }

        Mock -CommandName ConvertTo-ACETokenList -MockWith {
            return @("MockPermission")
        }
    }

    It "should return a singular item of ACEs when valid parameters are provided" {
        $result = ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(
            @{ Identity = "User1"; Permission = "Read" }
        ) -OrganizationName "MyOrg"

        $result | Should -Not -BeNullOrEmpty
        $result.Identity.Identity | Should -Be "MockIdentity"
        $result.Permissions | Should -Contain "MockPermission"
    }

    It "should return multiple items of ACEs when valid parameters are provided" {
        $result = ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(
            @{ Identity = "User1"; Permission = "Read" },
            @{ Identity = "User2"; Permission = "Write" }
        ) -OrganizationName "MyOrg"

        $result | Should -Not -BeNullOrEmpty
        $result | Should -HaveCount 2
        $result[0].Identity.Identity | Should -Be "MockIdentity"
        $result[0].Permissions | Should -Contain "MockPermission"
        $result[1].Identity.Identity | Should -Be "MockIdentity"
        $result[1].Permissions | Should -Contain "MockPermission"
    }

    It "should log a warning if the identity is not found" {
        Mock -CommandName Find-Identity -MockWith { return $null }
        Mock -CommandName Write-Warning -Verifiable

        { ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(@{ Identity = "User1"; Permission = "Read" }) -OrganizationName "MyOrg" } | Should -Not -Throw
        Assert-VerifiableMock

    }

    It "should log a warning if permissions are not found" {
        Mock -CommandName ConvertTo-ACETokenList -MockWith { return $null }
        Mock -CommandName Write-Warning -Verifiable

        $result = ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(@{ Identity = "User1"; Permission = "Read" }) -OrganizationName "MyOrg"
        $result | Should -BeNullOrEmpty
        Assert-VerifiableMock
    }

    It "should handle empty permissions array gracefully" {
        $result = ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @() -OrganizationName "MyOrg"

        $result | Should -BeNullOrEmpty
    }

}
