
Describe "Remove-AzDevOpsProject" {
    Mock -CommandName Test-AzDevOpsApiUri {
        return $true
    }

    Mock -CommandName Test-AzDevOpsPat {
        return $true
    }

    Mock -CommandName Test-AzDevOpsProjectId {
        return $true
    }

    Mock -CommandName Remove-AzDevOpsApiResource {
        return $null
    }

    Context "When Force parameter is not supplied" {
        It "Should call Remove-AzDevOpsApiResource with correct parameters if ShouldProcess is approved" {
            Remove-AzDevOpsProject -ApiUri "https://dev.azure.com/someOrganizationName/_apis/" -Pat "SomePat" -ProjectId "SomeProjectId" -Confirm:$false

            Assert-MockCalled -CommandName Remove-AzDevOpsApiResource -Exactly -Times 1 -Scope It -Parameters @{
                ApiUri = "https://dev.azure.com/someOrganizationName/_apis/"
                Pat = "SomePat"
                ResourceName = "Project"
                ResourceId = "SomeProjectId"
                Force = $false
                Wait = $true
            }
        }
    }

    Context "When Force parameter is supplied" {
        It "Should call Remove-AzDevOpsApiResource with Force parameter set to true" {
            Remove-AzDevOpsProject -ApiUri "https://dev.azure.com/someOrganizationName/_apis/" -Pat "SomePat" -ProjectId "SomeProjectId" -Force

            Assert-MockCalled -CommandName Remove-AzDevOpsApiResource -Exactly -Times 1 -Scope It -Parameters @{
                ApiUri = "https://dev.azure.com/someOrganizationName/_apis/"
                Pat = "SomePat"
                ResourceName = "Project"
                ResourceId = "SomeProjectId"
                Force = $true
                Wait = $true
            }
        }
    }
}

