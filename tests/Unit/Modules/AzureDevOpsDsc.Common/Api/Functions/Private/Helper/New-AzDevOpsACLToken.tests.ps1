powershell
# Unit Tests for New-AzDevOpsACLToken function
Describe 'New-AzDevOpsACLToken' {
    Context 'When TeamId is provided' {
        It 'Should create a team-level access token' {
            $OrganizationName = "Contoso"
            $ProjectId = "MyProject"
            $TeamId = "MyTeam"
            $expectedToken = "vstfs:///Classification/TeamProject/$ProjectId/$TeamId"
            
            $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId -TeamId $TeamId
            
            $result | Should -Be $expectedToken
        }
    }

    Context 'When TeamId is not provided' {
        It 'Should create a project-level access token' {
            $OrganizationName = "Contoso"
            $ProjectId = "MyProject"
            $expectedToken = "vstfs:///Classification/TeamProject/$ProjectId"
            
            $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId
            
            $result | Should -Be $expectedToken
        }
    }

    Context 'When required parameters are missing' {
        It 'Should throw an error if OrganizationName is missing' {
            { New-AzDevOpsACLToken -ProjectId "MyProject" } | Should -Throw
        }
        
        It 'Should throw an error if ProjectId is missing' {
            { New-AzDevOpsACLToken -OrganizationName "Contoso" } | Should -Throw
        }
    }
}

