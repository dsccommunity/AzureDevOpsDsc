powershell
Describe "New-GitRepository" {
    Mock Get-AzDevOpsApiVersion { "6.0-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod { 
        return @{
            name = $using:RepositoryName
        }
    }

    $params = @{
        ApiUri = "https://dev.azure.com/fakeorg"
        Project = [PSCustomObject]@{ name = "TestProject"; id = "12345" }
        RepositoryName = "TestRepo"
    }

    It "Creates a new repository successfully" {
        $result = New-GitRepository @params
        $result | Should -Not -BeNullOrEmpty
        $result.name | Should -Be $params.RepositoryName
    }

    It "Calls Get-AzDevOpsApiVersion if ApiVersion is not supplied" {
        $result = New-GitRepository @params
        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
    }

    It "Does not call Get-AzDevOpsApiVersion if ApiVersion is supplied" {
        $params.ApiVersion = "5.0"
        $result = New-GitRepository @params
        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0
    }

    It "Returns error if Invoke-AzDevOpsApiRestMethod throws an exception" {
        Mock Invoke-AzDevOpsApiRestMethod { throw "API error" }
        { New-GitRepository @params } | Should -Throw
    }

    Context "with SourceRepository" {
        $params.SourceRepository = "sourceRepo"
        It "Creates a new repository with source repository" {
            Mock Invoke-AzDevOpsApiRestMethod {
                $body = (ConvertFrom-Json $using:params.Body)
                $body | Add-Member -MemberType NoteProperty -Name 'sourceRepository' -Value $using:params.SourceRepository -Force
                return $body
            }
            $result = New-GitRepository @params
            $result.sourceRepository | Should -Be $params.SourceRepository
        }
    }
}

