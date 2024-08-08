Describe 'Test-AzDevOpsApiResourceId' {
    It 'Returns $true for a valid ResourceId' {
        $ValidResourceId = [guid]::NewGuid().ToString()
        $result = Test-AzDevOpsApiResourceId -ResourceId $ValidResourceId -IsValid
        $result | Should -Be $true
    }

    It 'Returns $false for an invalid ResourceId' {
        $InvalidResourceId = 'Invalid-GUID'
        $result = Test-AzDevOpsApiResourceId -ResourceId $InvalidResourceId -IsValid
        $result | Should -Be $false
    }

    It 'Throws exception if IsValid switch is not provided' {
        $ValidResourceId = [guid]::NewGuid().ToString()
        { Test-AzDevOpsApiResourceId -ResourceId $ValidResourceId } | Should -Throw
    }
}

