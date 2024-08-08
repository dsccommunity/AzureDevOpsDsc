Describe 'New-GitRepository' {
    $ApiUri = "https://dev.azure.com/organization"
    $Project = [PSCustomObject]@{ id = "project123"; name = "TestProject" }
    $RepositoryName = "NewRepo"
    $SourceRepository = "ExistingRepo"
    $ApiVersion = "6.0"

    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { "6.0" }

    Context 'When mandatory parameters are provided' {
        It 'should create a new repository' {
            $params = @{
                ApiUri = "$ApiUri/$($Project.name)/_apis/git/repositories?api-version=$ApiVersion"
                Method = 'POST'
                ContentType = 'application/json'
                Body = @{
                    name = $RepositoryName
                    project = @{
                        id = $Project.id
                    }
                } | ConvertTo-Json
            }

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                [PSCustomObject]@{ name = $RepositoryName }
            }

            $result = New-GitRepository -ApiUri $ApiUri -Project $Project -RepositoryName $RepositoryName
            $result.name | Should -Be $RepositoryName
        }

        It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -Verifiable

            $result = New-GitRepository -ApiUri $ApiUri -Project $Project -RepositoryName $RepositoryName

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Parameters @{
                ApiUri = "$ApiUri/$($Project.name)/_apis/git/repositories?api-version=$ApiVersion"
                Method = 'POST'
                ContentType = 'application/json'
                Body = @{
                    name = $RepositoryName
                    project = @{
                        id = $Project.id
                    }
                } | ConvertTo-Json
            }
        }
    }

    Context 'When an error occurs during repository creation' {
        It 'should catch the exception and write an error' {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API call failed" }

            { New-GitRepository -ApiUri $ApiUri -Project $Project -RepositoryName $RepositoryName } | Should -Throw
        }
    }
}

