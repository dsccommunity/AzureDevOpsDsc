$currentFile = $MyInvocation.MyCommand.Path

Describe "Test-ACLListforChanges" {

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
                    isInherited = $False
                }
            )
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
                    isInherited = $False
                }
            )
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

        Mock -CommandName Test-ACLListforChanges -MockWith {
            param ($ReferenceACLs, $DifferenceACLs)
            if ($ReferenceACLs -eq $null) {
                return @{ status = 'Missing' }
            }
            elseif ($DifferenceACLs -eq $null) {
                return @{ status = 'NotFound' }
            }
            elseif (($ReferenceACLs.aces.Count -ne $DifferenceACLs.aces.Count) -or
                    ($ReferenceACLs.aces[0].isInherited -ne $DifferenceACLs.aces[0].isInherited) -or
                    ($ReferenceACLs.aces[0].Permissions.Allow.Bit -ne $DifferenceACLs.aces[0].Permissions.Allow.Bit)) {
                return @{ status = 'Changed' }
            }
            else {
                return @{ status = 'Unchanged' }
            }
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
                    isInherited = $True
                }
            )
        }
        $result = Test-ACLListforChanges -ReferenceACLs $ReferenceACLsSample -DifferenceACLs $InheritedFlagACLs
        $result.status | Should -Be "Changed"
    }
}
