$currentFile = $MyInvocation.MyCommand.Path

# ConvertTo-FormattedACL.Tests.ps1

Describe "ConvertTo-FormattedACL" -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-FormattedACL.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Find-Identity -MockWith { return @{Id = "TestIdentity"} }
        Mock -CommandName Format-ACEs -MockWith { return @{ Permissions = "TestPermissions" } }
        Mock -CommandName Parse-ACLToken -MockWith { return "FormattedToken" }
        Mock -CommandName Write-Warning

    }

    Context "When ACL has token and ACE entries" {

        BeforeAll {

            $ACLList = @(
                @{
                    inheritPermissions = $true
                    token = "TestToken"
                    acesDictionary = [PSCustomObject]@{
                        "TestACE" = @{
                            descriptor = "TestDescriptor"
                            allow = 2
                            deny  = 0
                        }
                    }
                },
                @{
                    inheritPermissions = $true
                    token = "TestToken"
                    acesDictionary = [PSCustomObject]@{
                        "TestACE" = @{
                            descriptor = "TestDescriptor2"
                            allow = 2
                            deny  = 0
                        }
                    }
                }
            )

        }

        It "Should format ACL Git Repositories properly" {
            $result = $ACLList | ConvertTo-FormattedACL -SecurityNamespace "Git Repositories" -OrganizationName "TestOrg"
            $result.count | Should -Be 2
            $result[0].token | Should -Be "FormattedToken"
            $result[0].aces | Should -HaveCount 1
            $result[0].aces[0].Identity.Id | Should -Be "TestIdentity"
            $result[0].aces[0].Permissions.Permissions | Should -Be "TestPermissions"
        }

        It "Should format ACL Identity properly" {
            $result = $ACLList | ConvertTo-FormattedACL -SecurityNamespace "Identity" -OrganizationName "TestOrg"
            $result.count | Should -Be 2
            $result[0].token | Should -Be "FormattedToken"
            $result[0].aces | Should -HaveCount 1
            $result[0].aces[0].Identity.Id | Should -Be "TestIdentity"
            $result[0].aces[0].Permissions.Permissions | Should -Be "TestPermissions"
        }
    }

    Context "When ACL has no token" {

        BeforeAll {

            $ACLList = @(
                @{
                    inheritPermissions = $true
                    token = $null
                    acesDictionary = [PSCustomObject]@{
                        "TestACE" = @{
                            descriptor = "TestDescriptor"
                            allow = 2
                            deny  = 0
                        }
                    }
                },
                @{
                    inheritPermissions = $true
                    token = ""
                    acesDictionary = [PSCustomObject]@{
                        "TestACE" = @{
                            descriptor = "TestDescriptor2"
                            allow = 2
                            deny  = 0
                        }
                    }
                }
            )


        }

        It "Should skip ACL without token" {
            $result = $ACLList | ConvertTo-FormattedACL -SecurityNamespace "Git Repositories" -OrganizationName "TestOrg"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "When ACL has empty ACE entries" {

        BeforeAll {

            $ACLList = @(
                @{
                    inheritPermissions = $true
                    token = $null
                    acesDictionary = [PSCustomObject]@{
                        "TestACE" = @{
                            descriptor = "TestDescriptor"
                            allow = 2
                            deny  = 0
                        }
                    }
                }
            )

        }

        It "Should skip ACL with empty ACE entries" {
            $result = $ACLList | ConvertTo-FormattedACL -SecurityNamespace "Identity" -OrganizationName "TestOrg"
            $result | Should -BeNullOrEmpty
        }
    }

}
