powershell
Describe 'Remove-GitRepository' {
    Mock Get-AzDevOpsApiVersion { return '6.0' }
    Mock Invoke-AzDevOpsApiRestMethod

    BeforeAll {
        # Test data
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject"; id = "123-456" }
        $Repository = [PSCustomObject]@{ name = "SampleRepo"; id = "789-012" }
        $ApiVersion = "6.0"
    }

    It 'Removes the repository successfully' {
        Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository -ApiVersion $ApiVersion

        # Verify the function called the Invoked method correctly
        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It
        Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Times 0 -Scope It
    }

    It 'Uses default API version if not supplied' {
        Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository

        # Verify the function calls Get-AzDevOpsApiVersion to get the default API version
        Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly 1 -Scope It
    }

    It 'Writes an error when it fails to remove the repository' {
        Mock Invoke-AzDevOpsApiRestMethod { throw "Failed to call API" }

        { Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository } |
        Should -Throw

        # Assert error
        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It
    }

    AfterEach {
        Remove-Mock -CommandName Invoke-AzDevOpsApiRestMethod
        Remove-Mock -CommandName Get-AzDevOpsApiVersion
    }
}

