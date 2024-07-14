
# Mock data for unit tests
$LocalizedDataAzACLTokenPatten = @{
    OrganizationGit = "^org\/(?<Organization>[^\/]+)$"
    GitProject = "^org\/(?<Organization>[^\/]+)\/proj\/(?<Project>[^\/]+)$"
    GitRepository = "^org\/(?<Organization>[^\/]+)\/proj\/(?<Project>[^\/]+)\/repo\/(?<Repository>[^\/]+)$"
    GitBranch = "^org\/(?<Organization>[^\/]+)\/proj\/(?<Project>[^\/]+)\/repo\/(?<Repository>[^\/]+)\/branch\/(?<Branch>[^\/]+)$"
}

Describe "Parse-ACLToken" {
    BeforeAll {
        function Global:Get-LocalizedData { 
            return @{ AzACLTokenPatten = $LocalizedDataAzACLTokenPatten }
        }
    }
    
    It "parses Organization Git token" {
        $token = "org/my-org"
        $expected = @{
            type = "OrganizationGit"
            Organization = "my-org"
            _token = "org/my-org"
        }
        { Parse-ACLToken -Token $token } | Should -Not -Throw
        $result = Parse-ACLToken -Token $token
        $result | Should -BeExactly $expected
    }

    It "parses Git Project token" {
        $token = "org/my-org/proj/my-proj"
        $expected = @{
            type = "GitProject"
            Organization = "my-org"
            Project = "my-proj"
            _token = "org/my-org/proj/my-proj"
        }
        { Parse-ACLToken -Token $token } | Should -Not -Throw
        $result = Parse-ACLToken -Token $token
        $result | Should -BeExactly $expected
    }

    It "parses Git Repository token" {
        $token = "org/my-org/proj/my-proj/repo/my-repo"
        $expected = @{
            type = "GitRepository"
            Organization = "my-org"
            Project = "my-proj"
            Repository = "my-repo"
            _token = "org/my-org/proj/my-proj/repo/my-repo"
        }
        { Parse-ACLToken -Token $token } | Should -Not -Throw
        $result = Parse-ACLToken -Token $token
        $result | Should -BeExactly $expected
    }

    It "parses Git Branch token" {
        $token = "org/my-org/proj/my-proj/repo/my-repo/branch/my-branch"
        $expected = @{
            type = "GitBranch"
            Organization = "my-org"
            Project = "my-proj"
            Repository = "my-repo"
            Branch = "my-branch"
            _token = "org/my-org/proj/my-proj/repo/my-repo/branch/my-branch"
        }
        { Parse-ACLToken -Token $token } | Should -Not -Throw
        $result = Parse-ACLToken -Token $token
        $result | Should -BeExactly $expected
    }

    It "throws error for unrecognized token" {
        $token = "invalid-token"
        { Parse-ACLToken -Token $token } | Should -Throw -Error
    }
}

