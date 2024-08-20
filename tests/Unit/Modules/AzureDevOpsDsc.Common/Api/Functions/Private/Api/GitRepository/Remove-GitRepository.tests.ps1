$currentFile = $MyInvocation.MyCommand.Path

Describe "Remove-GitRepository" {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "5.0" }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod

    }

    It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject" }
        $Repository = [PSCustomObject]@{ id = "123"; Name = "SampleRepo" }

        Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -ParameterFilter {
            $ApiUri -eq "https://dev.azure.com/organization/SampleProject/_apis/git/repositories/123?api-version=5.0" -and
            $Method -eq 'Delete'
        }
    }

    It "Should use the provided ApiVersion if specified" {
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject" }
        $Repository = [PSCustomObject]@{ id = "123"; Name = "SampleRepo" }
        $ApiVersion = "6.0"

        Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository -ApiVersion $ApiVersion

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -ParameterFilter {
            $ApiUri -eq "https://dev.azure.com/organization/SampleProject/_apis/git/repositories/123?api-version=6.0" -and
            $Method -eq 'Delete'
        }
    }

    It "Should handle and display the error if Invoke-AzDevOpsApiRestMethod throws an exception" {
        $ApiUri = "https://dev.azure.com/organization"
        $Project = [PSCustomObject]@{ name = "SampleProject" }
        $Repository = [PSCustomObject]@{ id = "123"; Name = "SampleRepo" }

        Mock -CommandName Write-Error -Verifiable
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API Error" }

        { Remove-GitRepository -ApiUri $ApiUri -Project $Project -Repository $Repository } | Should -Not -Throw

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
    }
}

