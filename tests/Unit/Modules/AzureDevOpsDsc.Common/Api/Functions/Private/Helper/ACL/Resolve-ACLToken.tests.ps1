Describe 'Resolve-ACLToken' {
    $referenceObject = [PSCustomObject]@{ token = [PSCustomObject]@{ _token = 'refToken' } }
    $differenceObject = [PSCustomObject]@{ token = [PSCustomObject]@{ _token = 'diffToken' } }

    Context 'When DifferenceObject is not null' {
        It 'should return the token from DifferenceObject' {
            $result = Resolve-ACLToken -ReferenceObject $referenceObject -DifferenceObject $differenceObject
            $result | Should -Be 'diffToken'
        }
    }

    Context 'When DifferenceObject is null' {
        It 'should return the token from ReferenceObject' {
            $result = Resolve-ACLToken -ReferenceObject $referenceObject -DifferenceObject $null
            $result | Should -Be 'refToken'
        }
    }

    Context 'When both DifferenceObject and ReferenceObject are null' {
        It 'should return $null' {
            $result = Resolve-ACLToken -ReferenceObject $null -DifferenceObject $null
            $result | Should -Be $null
        }
    }
}

