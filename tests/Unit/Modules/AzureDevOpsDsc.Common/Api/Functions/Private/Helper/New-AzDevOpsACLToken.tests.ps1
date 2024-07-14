
Describe 'New-AzDevOpsACLToken' {
    BeforeAll {
        Import-Module -Name "Path\To\Your\Module" # Adjust path to the module containing the function
    }

    Context 'When TeamId is provided' {
        It 'should create a token for team-level access' {
            $OrganizationName = "Contoso"
            $ProjectId = "MyProject"
            $TeamId = "MyTeam"

            $expectedToken = "vstfs:///Classification/TeamProject/MyProject/MyTeam"

            $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId -TeamId $TeamId
            $result | Should -Be $expectedToken
        }
    }

    Context 'When TeamId is not provided' {
        It 'should create a token for project-level access' {
            $OrganizationName = "Contoso"
            $ProjectId = "MyProject"

            $expectedToken = "vstfs:///Classification/TeamProject/MyProject"

            $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId
            $result | Should -Be $expectedToken
        }
    }

    Context 'When mandatory parameters are not provided' {
        It 'should throw an error when OrganizationName is missing' {
            { New-AzDevOpsACLToken -ProjectId "MyProject" } | Should -Throw
        }

        It 'should throw an error when ProjectId is missing' {
            { New-AzDevOpsACLToken -OrganizationName "Contoso" } | Should -Throw
        }
    }
}

