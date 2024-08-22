Describe 'Refresh-CacheObject' -skip {
    BeforeAll {
        # Mocking Get-AzDoCacheObjects to return a controlled list
        Mock -CommandName 'Get-AzDoCacheObjects' -MockWith { @('Type1', 'Type2', 'Type3') }

        # Defining the function to test
        function Refresh-CacheObject
        {
            param (
                [Parameter(Mandatory)]
                [ValidateScript({$_ -in (Get-AzDoCacheObjects)})]
                [string] $Type
            )
        }
    }

    Context 'Valid Type' {
        It 'Accepts a valid type from the cache' {
            Refresh-CacheObject -Type 'Type1' | Should -Not -Throw
        }
    }

    Context 'Invalid Type' -Skip {
        It 'Throws an error for invalid type' {
            Wait-Debugger
            { Refresh-CacheObject -Type 'InvalidType' } | Should -Throw
        }
    }

}

