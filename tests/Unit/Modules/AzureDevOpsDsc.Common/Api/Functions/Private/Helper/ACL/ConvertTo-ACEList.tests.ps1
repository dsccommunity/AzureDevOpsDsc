$currentFile = $MyInvocation.MyCommand.Path

Describe "ConvertTo-ACEList" {

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

    It "should return a list of ACEs when valid parameters are provided" {
        $result = ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(@{ Identity = "User1"; Permission = "Read" }) -OrganizationName "MyOrg"

        $result | Should -Not -BeNullOrEmpty
        $result[0].Identity.Identity | Should -Be "MockIdentity"
        $result[0].Permissions | Should -Contain "MockPermission"
    }

    It "should log a warning if the identity is not found" {
        Mock -CommandName Find-Identity -MockWith { return $null }

        { ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(@{ Identity = "User1"; Permission = "Read" }) -OrganizationName "MyOrg" } | Should -Throw
    }

    It "should log a warning if permissions are not found" {
        Mock -CommandName ConvertTo-ACETokenList -ParameterFilter {
            param (
                [string]$SecurityNamespace,
                [string]$ACEPermissions
            )
            return $true
        } -MockWith { return $null }

        { ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(@{ Identity = "User1"; Permission = "Read" }) -OrganizationName "MyOrg" } | Should -Throw
    }

    It "should handle empty permissions array gracefully" {
        $result = ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @() -OrganizationName "MyOrg"

        $result | Should -BeNullOrEmpty
    }

    It "should throw an error if mandatory parameters are missing" {
        { ConvertTo-ACEList -SecurityNamespace "Namespace" -Permissions @(@{ Identity = "User1"; Permission = "Read" }) } | Should -Throw
        { ConvertTo-ACEList -SecurityNamespace "Namespace" -OrganizationName "MyOrg" } | Should -Throw
        { ConvertTo-ACEList -Permissions @(@{ Identity = "User1"; Permission = "Read" }) -OrganizationName "MyOrg" } | Should -Throw
    }
}
