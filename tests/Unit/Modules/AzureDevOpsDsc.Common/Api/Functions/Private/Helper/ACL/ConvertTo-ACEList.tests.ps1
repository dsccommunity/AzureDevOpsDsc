
# Module: ConvertTo-ACEList.Tests.ps1

Describe "ConvertTo-ACEList" {
    BeforeEach {
        function Find-Identity {
            param (
                [string]$Name,
                [string]$OrganizationName,
                [string]$SearchType
            )
            return "$Name-Found"
        }

        function ConvertTo-ACETokenList {
            param (
                [string]$SecurityNamespace,
                [string]$ACEPermissions
            )
            return "$ACEPermissions-Token"
        }
    }
    
    It "Should return ACEs with valid input" {
        $SecurityNamespace = "Namespace"
        $Permissions = @(
            [PSCustomObject]@{ Identity = "User1"; Permission = "Read" },
            [PSCustomObject]@{ Identity = "User2"; Permission = "Write" }
        )
        $OrganizationName = "MyOrg"

        $result = ConvertTo-ACEList -SecurityNamespace $SecurityNamespace -Permissions $Permissions -OrganizationName $OrganizationName

        $result | Should -HaveCount 2
        $result | Should -Contain @{
            Identity = "User1-Found"
            Permissions = "Read-Token"
        }
        $result | Should -Contain @{
            Identity = "User2-Found"
            Permissions = "Write-Token"
        }
    }

    It "Should handle missing identity gracefully" {
        function Find-Identity {
            param (
                [string]$Name,
                [string]$OrganizationName,
                [string]$SearchType
            )
            return $null
        }
        
        $SecurityNamespace = "Namespace"
        $Permissions = @(
            [PSCustomObject]@{ Identity = "UnknownUser"; Permission = "Read" }
        )
        $OrganizationName = "MyOrg"
        
        $result = ConvertTo-ACEList -SecurityNamespace $SecurityNamespace -Permissions $Permissions -OrganizationName $OrganizationName

        $result | Should -BeEmpty
    }

    It "Should handle missing permissions gracefully" {
        function ConvertTo-ACETokenList {
            param (
                [string]$SecurityNamespace,
                [string]$ACEPermissions
            )
            return $null
        }
        
        $SecurityNamespace = "Namespace"
        $Permissions = @(
            [PSCustomObject]@{ Identity = "User1"; Permission = "UnknownPermission" }
        )
        $OrganizationName = "MyOrg"
        
        $result = ConvertTo-ACEList -SecurityNamespace $SecurityNamespace -Permissions $Permissions -OrganizationName $OrganizationName

        $result | Should -BeEmpty
    }

    It "Should return empty list when no permissions are provided" {
        $SecurityNamespace = "Namespace"
        $Permissions = @()
        $OrganizationName = "MyOrg"
        
        $result = ConvertTo-ACEList -SecurityNamespace $SecurityNamespace -Permissions $Permissions -OrganizationName $OrganizationName

        $result | Should -BeEmpty
    }
}

