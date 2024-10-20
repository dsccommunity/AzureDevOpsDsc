$currentFile = $MyInvocation.MyCommand.Path

Describe "Test-ACLListforChanges" -Tags "Unit", "ACL", "Helper" {

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-ACLListforChanges.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the classes to test
        . (Get-ClassFilePath 'Get-BitwiseOrResult.ps1')

        # Mock Data
        $ReferenceACLsSample = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                }
            )
            isInherited = $False
        }

        $DifferenceACLsSample = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                }
            )
            isInherited = $False
        }

        $ModifiedDifferenceACLsSample = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 2
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                    isInherited = $False
                }
            )
        }

    }

    It "Returns Unchanged when ACLs are identical" {
        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $DifferenceACLsSample
        $result.status | Should -Be "Unchanged"
    }

    It "Returns Changed when ACLs are different" {
        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $ModifiedDifferenceACLsSample
        $result.status | Should -Be "Changed"
    }

    It "Returns Missing when Reference ACL is null" {
        $result = Test-ACLListforChanges -ReferenceACLs $null -DifferenceACLs $DifferenceACLsSample
        $result.status | Should -Be "Missing"
    }

    It "Returns NotFound when Difference ACL is null" {
        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $null
        $result.status | Should -Be "NotFound"
    }

    It "Returns Changed when ACLs count is not equal" {
        $DifferentCountACLs = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                    isInherited = $False
                },
                @{
                    Identity = @{
                        value = @{
                            originId = 2
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                    isInherited = $False
                }
            )
        }
        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $DifferentCountACLs
        $result.status | Should -Be "Changed"
    }

    It "Returns Changed when inherited flag is not equal" {
        $InheritedFlagACLs = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                }
            )
            isInherited = $True
        }

        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $InheritedFlagACLs
        $result.status | Should -Be "Changed"

    }

    It "Returns Changed when ACE is not found in Difference ACL" {
        $MissingACEACLs = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 2
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                }
            )
            isInherited = $False
        }

        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $MissingACEACLs
        $result.status | Should -Be "Changed"
    }

    It "Returns Changed when Allow ACEs are not equal" {
        $DifferentAllowACLs = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 2
                        }
                        Deny = @{
                            Bit = 0
                        }
                    }
                }
            )
            isInherited = $False
        }

        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $DifferentAllowACLs
        $result.status | Should -Be "Changed"
    }

    It "Returns Changed when Deny ACEs are not equal" {
        $DifferentDenyACLs = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 1
                        }
                        Deny = @{
                            Bit = 1
                        }
                    }
                }
            )
            isInherited = $False
        }

        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $DifferentDenyACLs
        $result.status | Should -Be "Changed"
    }

    It "Returns Changed when ACLs are different" {
        $DifferentACLs = @{
            aces = @(
                @{
                    Identity = @{
                        value = @{
                            originId = 1
                        }
                    }
                    Permissions = @{
                        Allow = @{
                            Bit = 2
                        }
                        Deny = @{
                            Bit = 1
                        }
                    }
                }
            )
            isInherited = $False
        }

        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $DifferentACLs
        $result.status | Should -Be "Changed"
    }

}
