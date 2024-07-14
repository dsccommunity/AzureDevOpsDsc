
# ConvertTo-FormattedACL.Tests.ps1

Describe "ConvertTo-FormattedACL" {

    BeforeAll {
        function Find-Identity {
            param (
                [string]$Name,
                [string]$OrganizationName
            )
            return "$Name@$OrganizationName"
        }

        function Format-ACEs {
            param (
                [string]$Allow,
                [string]$Deny,
                [string]$SecurityNamespace
            )
            return "Allow: $Allow, Deny: $Deny, Namespace: $SecurityNamespace"
        }

        function Parse-ACLToken {
            param (
                [string]$Token
            )
            return "ParsedToken_$Token"
        }

        $SampleACL = [PSCustomObject]@{
            token = "SampleToken"
            acesDictionary = @{
                "User1" = [PSCustomObject]@{
                    allow = "Read"
                    deny  = "Write"
                }
                "User2" = [PSCustomObject]@{
                    allow = "Execute"
                    deny  = "Delete"
                }
            }
            inheritPermissions = $true
        }

        $SecurityNamespace = "MyNamespace"
        $OrganizationName = "MyOrganization"
    }

    It "should return formatted ACLs" {
        $formattedACL = $SampleACL | ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName

        $formattedACL | Should -Not -BeNull
        $formattedACL.Count | Should -Be 1

        $formattedACL[0].token | Should -Be "ParsedToken_SampleToken"
        $formattedACL[0].inherited | Should -Be $true

        $formattedACL[0].aces.Count | Should -Be 2

        $formattedACL[0].aces[0].Name | Should -Be "User1"
        $formattedACL[0].aces[0].Identity | Should -Be "User1@MyOrganization"
        $formattedACL[0].aces[0].Permissions | Should -Be "Allow: Read, Deny: Write, Namespace: MyNamespace"

        $formattedACL[0].aces[1].Name | Should -Be "User2"
        $formattedACL[0].aces[1].Identity | Should -Be "User2@MyOrganization"
        $formattedACL[0].aces[1].Permissions | Should -Be "Allow: Execute, Deny: Delete, Namespace: MyNamespace"
    }
}

