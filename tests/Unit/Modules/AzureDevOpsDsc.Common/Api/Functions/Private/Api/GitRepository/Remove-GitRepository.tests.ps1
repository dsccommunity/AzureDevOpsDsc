
Describe "Remove-GitRepository" {
    Mock -ModuleName <YourModuleName> -CommandName Get-AzDevOpsApiVersion -MockWith { return "5.0" }
    Mock -ModuleName <YourModuleName> -CommandName Invoke-AzDevOpsApiRestMethod

    It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject" }
        $Repository = [PSCustomObject]@{ id = "123"; Name = "SampleRepo" }

        Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository

        Assert-MockCalled -ModuleName <YourModuleName> -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
            $params.ApiUri -eq "https://dev.azure.com/organization/SampleProject/_apis/git/repositories/123?api-version=5.0" -and
            $params.Method -eq 'Delete'
        }
    }

    It "Should use the provided ApiVersion if specified" {
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject" }
        $Repository = [PSCustomObject]@{ id = "123"; Name = "SampleRepo" }
        $ApiVersion = "6.0"

        Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository -ApiVersion $ApiVersion

        Assert-MockCalled -ModuleName <YourModuleName> -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
            $params.ApiUri -eq "https://dev.azure.com/organization/SampleProject/_apis/git/repositories/123?api-version=6.0" -and
            $params.Method -eq 'Delete'
        }
    }

    It "Should handle and display the error if Invoke-AzDevOpsApiRestMethod throws an exception" {
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject" }
        $Repository = [PSCustomObject]@{ id = "123"; Name = "SampleRepo" }

        Mock -ModuleName <YourModuleName> -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API Error" }

        { Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository } | Should -Throw

        Assert-MockCalled -ModuleName <YourModuleName> -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
    }
}

