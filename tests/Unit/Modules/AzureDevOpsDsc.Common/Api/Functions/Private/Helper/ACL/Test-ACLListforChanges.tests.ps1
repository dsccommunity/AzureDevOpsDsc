Describe "Test-ACLListforChanges" {

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

