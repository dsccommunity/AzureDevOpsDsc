powershell
# Pester Unit Tests for Wait-DevOpsProject

Describe "Wait-DevOpsProject" {
    Mock Invoke-AzDevOpsApiRestMethod

    BeforeEach {
        Clear-Mock
    }

    It "should wait until project is wellFormed" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{
                status = 'creating'
            },
            @{
                status = 'creating'
            },
            @{
                status = 'wellFormed'
            }
        }

        { Wait-DevOpsProject -OrganizationName "MyOrg" -ProjectURL "https://dev.azure.com/MyOrg/MyProject" } | Should -Not -Throw

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 3
    }

    It "should handle project creation failure" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{
                status = 'failed'
            }
        }

        { Wait-DevOpsProject -OrganizationName "MyOrg" -ProjectURL "https://dev.azure.com/MyOrg/MyProject" } | Should -Throw

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1
    }

    It "should time out waiting for project creation" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{
                status = 'creating'
            }
        }

        { Wait-DevOpsProject -OrganizationName "MyOrg" -ProjectURL "https://dev.azure.com/MyOrg/MyProject" } | Should -Throw

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 10
    }

    It "should handle unknown status" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{
                status = 'unknown'
            }
        }

        { Wait-DevOpsProject -OrganizationName "MyOrg" -ProjectURL "https://dev.azure.com/MyOrg/MyProject" } | Should -Throw

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1
    }

    It "should use the default API version if not specified" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{
                status = 'wellFormed'
            }
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith {
            return "6.0"
        }

        { Wait-DevOpsProject -OrganizationName "MyOrg" -ProjectURL "https://dev.azure.com/MyOrg/MyProject" } | Should -Not -Throw

        Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Times 1
    }
}

