Describe "Remove-xAzDoPermission Unit Tests" {

    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { "6.0-preview.1" }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    Context "When called with mandatory parameters" {
        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            $orgName = "testOrg"
            $secNamespaceID = "testNamespaceID"
            $token = "testToken"

            Remove-xAzDoPermission -OrganizationName $orgName -SecurityNamespaceID $secNamespaceID -TokenName $token

            $expectedUri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?tokens={2}&recurse=False&api-version={3}" -f $orgName, $secNamespaceID, $token, "6.0-preview.1"

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -Parameters @{
                Uri = $expectedUri
                Method = 'DELETE'
            }
        }
    }

    Context "When an exception occurs" {
        It "Should catch the exception and write an error message" {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API error" }

            {
                Remove-xAzDoPermission -OrganizationName "testOrg" -SecurityNamespaceID "testNamespaceID" -TokenName "testToken"
            } | Should -Throw

            Assert-MockCalled -CommandName Write-Error -Exactly -Times 1 -Scope It -Parameters @("[Remove-xAzDoPermission] Failed to add member to group: API error")
        }
    }
}

