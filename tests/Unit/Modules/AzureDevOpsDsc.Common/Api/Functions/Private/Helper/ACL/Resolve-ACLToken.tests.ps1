$currentFile = $MyInvocation.MyCommand.Path

Describe 'Resolve-ACLToken' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Resolve-ACLToken.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        $referenceObject = [PSCustomObject]@{ token = [PSCustomObject]@{ _token = 'refToken' } }
        $differenceObject = [PSCustomObject]@{ token = [PSCustomObject]@{ _token = 'diffToken' } }

        # If there were any Mock commands needed, they should be added here using the complete syntax.
        # Example:
        # Mock -CommandName Resolve-ACLToken -MockWith {
        #     param ($ReferenceObject, $DifferenceObject)
        #     if ($DifferenceObject -ne $null) {
        #         return $DifferenceObject.token._token
        #     }
        #     elseif ($ReferenceObject -ne $null) {
        #         return $ReferenceObject.token._token
        #     }
        #     else {
        #         return $null
        #     }
        # }
    }

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
