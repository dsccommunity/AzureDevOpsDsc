powershell
Describe 'Remove-GitRepository' {
    Mock -ModuleName 'Az.DevOps' -CommandName 'Get-AzDevOpsApiVersion' -MockWith { '5.1-preview' }
    Mock -ModuleName 'Az.DevOps' -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith { }

    $ApiUri = "https://dev.azure.com/example"
    $Project = [PSCustomObject]@{ name = "ExampleProject" }
    $Repository = [PSCustomObject]@{ id = "repo123"; Name = "ExampleRepo" }

    Context 'When all parameters are valid' {
        It 'Successfully removes a Git repository' {
            Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository

            Assert-MockCalled -ModuleName 'Az.DevOps' -CommandName 'Get-AzDevOpsApiVersion' -Exactly 1
            Assert-MockCalled -ModuleName 'Az.DevOps' -CommandName 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -ParameterFilter { 
                $PSCmdlet.MyInvocation.BoundParameters['ApiUri'] -eq "https://dev.azure.com/example/ExampleProject/_apis/git/repositories/repo123?api-version=5.1-preview" -and
                $PSCmdlet.MyInvocation.BoundParameters['Method'] -eq 'Delete'
            }
        }
    }

    Context 'When API version is provided' {
        It 'Uses the provided API version for removal' {
            $ApiVersion = "6.0"
            Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository -ApiVersion $ApiVersion

            Assert-MockCalled -ModuleName 'Az.DevOps' -CommandName 'Get-AzDevOpsApiVersion' -Exactly 0
            Assert-MockCalled -ModuleName 'Az.DevOps' -CommandName 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -ParameterFilter { 
                $PSCmdlet.MyInvocation.BoundParameters['ApiUri'] -eq "https://dev.azure.com/example/ExampleProject/_apis/git/repositories/repo123?api-version=6.0" -and
                $PSCmdlet.MyInvocation.BoundParameters['Method'] -eq 'Delete'
            }
        }
    }

    Context 'When there is an error during API call' {
        Mock -ModuleName 'Az.DevOps' -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith { throw "API call failed" }

        It 'Catches the error and writes an error message' {
            { Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository } | Should -Throw

            $errorMessage = "[Remove-GitRepository] Failed to Create Repository: API call failed"
            $Error[0].ToString() | Should -Contain $errorMessage
        }
    }
}

