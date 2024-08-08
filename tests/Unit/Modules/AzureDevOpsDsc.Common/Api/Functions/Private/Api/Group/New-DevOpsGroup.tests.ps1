powershell
# ModuleName: DevOpsGroup.Tests.ps1

Import-Module Pester
Import-Module ./YourModule.psm1

Describe "New-DevOpsGroup" {
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    Context "Parameter Validation" {
        It "Throws an error if ApiUri is not provided" {
            { New-DevOpsGroup -GroupName "MyGroup" } | Should -Throw
        }

        It "Throws an error if GroupName is not provided" {
            { New-DevOpsGroup -ApiUri "https://dev.azure.com/myorganization" } | Should -Throw
        }
    }

    Context "Functionality" {
        $params = @{
            ApiUri   = "https://dev.azure.com/myorganization"
            GroupName = "MyGroup"
        }

        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            New-DevOpsGroup @params

            $expectedBody = @{
                displayName = "MyGroup"
                description = $null
            } | ConvertTo-Json

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $_.Uri -eq "https://dev.azure.com/myorganization/_apis/graph/groups?api-version=$(Get-AzDevOpsApiVersion -Default)" -and
                $_.Method -eq 'Post' -and
                $_.ContentType -eq 'application/json' -and
                $_.Body -eq $expectedBody
            }
        }

        It "Should handle project scope descriptor" {
            $params.ProjectScopeDescriptor = "vstfs:///Classification/TeamProject/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
            New-DevOpsGroup @params

            $expectedUri = "https://dev.azure.com/myorganization/_apis/graph/groups?scopeDescriptor=vstfs:///Classification/TeamProject/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx&api-version=$(Get-AzDevOpsApiVersion -Default)"
            $expectedBody = @{
                displayName = "MyGroup"
                description = $null
            } | ConvertTo-Json

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $_.Uri -eq $expectedUri -and
                $_.Method -eq 'Post' -and
                $_.ContentType -eq 'application/json' -and
                $_.Body -eq $expectedBody
            }
        }
    }

    Context "Error Handling" {
        It "Should write an error if Invoke-AzDevOpsApiRestMethod throws an exception" {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API call failed" }
            $errorMessage = "Failed to create group: API call failed"

            { New-DevOpsGroup -ApiUri "https://dev.azure.com/myorganization" -GroupName "MyGroup" } | Should -Throw -ExceptionMessage $errorMessage
        }
    }
}


