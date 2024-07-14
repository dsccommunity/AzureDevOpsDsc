powershell
Describe "Resolve-ACLToken" {
    It "should return token from DifferenceObject when DifferenceObject is not null" {
        $ReferenceObject = @()
        $DifferenceObject = @{
            token = @{
                _token = "DifferenceToken"
            }
        }

        $result = Resolve-ACLToken -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject
        $result | Should -Be "DifferenceToken"
    }

    It "should return token from ReferenceObject when DifferenceObject is null" {
        $ReferenceObject = @{
            token = @{
                _token = "ReferenceToken"
            }
        }
        $DifferenceObject = $null

        $result = Resolve-ACLToken -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject
        $result | Should -Be "ReferenceToken"
    }

    It "should handle both ReferenceObject and DifferenceObject being null" {
        $ReferenceObject = @()
        $DifferenceObject = $null

        { Resolve-ACLToken -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject } | Should -Throw
    }

    It "should handle token being nested in array for ReferenceObject" {
        $ReferenceObject = @(
            @{
                token = @{
                    _token = "NestedReferenceToken"
                }
            }
        )
        $DifferenceObject = $null

        $result = Resolve-ACLToken -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject
        $result | Should -Be "NestedReferenceToken"
    }

    It "should handle token being nested in array for DifferenceObject" {
        $ReferenceObject = @()
        $DifferenceObject = @(
            @{
                token = @{
                    _token = "NestedDifferenceToken"
                }
            }
        )

        $result = Resolve-ACLToken -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject
        $result | Should -Be "NestedDifferenceToken"
    }
}

