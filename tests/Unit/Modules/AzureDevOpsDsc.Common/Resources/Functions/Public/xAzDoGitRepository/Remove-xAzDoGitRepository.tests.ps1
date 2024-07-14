powershell
Describe 'Remove-xAzDoGitRepository' {
    
    Mock -CommandName Get-CacheItem {
        return @{
            Key   = "$ProjectName\$RepositoryName"
            Value = "RepositoryValue"
        }
    }

    Mock -CommandName Remove-GitRepository {
        return @{
            Name = $RepositoryName
        }
    }

    Mock -CommandName Remove-CacheItem {}

    Mock -CommandName Export-CacheObject {}

    $params = @{
        ProjectName = "TestProject"
        RepositoryName = "TestRepository"
        Ensure = "Present"
    }

    It 'Calls Get-CacheItem with appropriate parameters for Project' {
        Remove-xAzDoGitRepository @params

        Assert-MockCalled -CommandName Get-CacheItem -Times 1 -Exactly -ParameterFilter {
            $Key -eq "TestProject" -and $Type -eq "LiveProjects"
        }
    }

    It 'Calls Get-CacheItem with appropriate parameters for Repository' {
        Remove-xAzDoGitRepository @params

        Assert-MockCalled -CommandName Get-CacheItem -Times 1 -Exactly -ParameterFilter {
            $Key -eq "TestProject\TestRepository" -and $Type -eq "LiveRepositories"
        }
    }

    It 'Calls Remove-GitRepository with appropriate parameters' {
        Remove-xAzDoGitRepository @params

        Assert-MockCalled -CommandName Remove-GitRepository -Times 1 -Exactly -ParameterFilter {
            $ApiUri -eq "https://dev.azure.com/{0}/" -f $Global:DSCAZDO_OrganizationName -and
            $Project -eq "RepositoryValue" -and
            $Repository -eq "RepositoryValue"
        }
    }

    It 'Calls Remove-CacheItem with appropriate parameters' {
        Remove-xAzDoGitRepository @params

        Assert-MockCalled -CommandName Remove-CacheItem -Times 1 -Exactly -ParameterFilter {
            $Key -eq "TestProject\TestRepository" -and $Type -eq "LiveRepositories"
        }
    }

    It 'Calls Export-CacheObject with appropriate parameters' {
        Remove-xAzDoGitRepository @params

        Assert-MockCalled -CommandName Export-CacheObject -Times 1 -Exactly -ParameterFilter {
            $CacheType -eq 'LiveRepositories' -and $Content -eq $AzDoLiveRepositories
        }
    }
}

