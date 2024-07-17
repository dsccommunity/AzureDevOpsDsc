powershell
Describe "List-DevOpsGroupMembers Tests" {

    Mock -ModuleName Az.DevOps -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
        @{
            value = @(
                @{ displayName = "User1"; principalName = "user1@domain.com" }
                @{ displayName = "User2"; principalName = "user2@domain.com" }
            )
        }
    }

    It "should return group members when valid parameters are passed" {
        $Organization = "myOrganization"
        $GroupDescriptor = "someGroupDescriptor"
        
        $result = List-DevOpsGroupMembers -Organization $Organization -GroupDescriptor $GroupDescriptor

        $result | Should -Not -BeNullOrEmpty
        $result | Should -HaveCount 2
        $result[0].displayName | Should -Be "User1"
        $result[1].displayName | Should -Be "User2"
    }

    It "should return null when no members are found" {
        Mock -ModuleName Az.DevOps -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            @{ value = $null }
        }
        
        $Organization = "myOrganization"
        $GroupDescriptor = "someOtherGroupDescriptor"

        $result = List-DevOpsGroupMembers -Organization $Organization -GroupDescriptor $GroupDescriptor

        $result | Should -BeNull
    }

    It "should call the API with the correct parameters" {
        $Organization = "myOrganization"
        $GroupDescriptor = "someGroupDescriptor"
        $expectedUri = "https://vssps.dev.azure.com/{0}/_apis/graph/Memberships/{1}?direction=down" -f $Organization, $GroupDescriptor

        List-DevOpsGroupMembers -Organization $Organization -GroupDescriptor $GroupDescriptor

        Assert-MockCalled -ModuleName Az.DevOps -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -Exactly {
            Param (
                $params
            )
            $params.Uri | Should -Be $expectedUri
            $params.Method | Should -Be "Get"
        }
    }
}

