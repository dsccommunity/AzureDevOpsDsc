powershell
Describe "Set-xAzDoPermission Unit Tests" {

    Mock -ModuleName YourModule -FunctionName Get-AzDevOpsApiVersion {
        "5.1-preview.1"
    }

    Mock -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod

    $fakeOrgName = "FakeOrg"
    $fakeSecurityNamespaceID = "FakeID"
    $fakeSerializedACLs = [pscustomobject]@{ a = "b" }
    $fakeApiVersion = "5.1-preview.1"

    BeforeEach {
        Clear-Host
    }

    Context "When parameters are correctly passed" {
        It "Should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            Set-xAzDoPermission -OrganizationName $fakeOrgName -SecurityNamespaceID $fakeSecurityNamespaceID -SerializedACLs $fakeSerializedACLs -ApiVersion $fakeApiVersion

            Mock -Assert -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod { Param ([string]$Uri, [string]$Method, [string]$Body)}

            $actualUri = "https://dev.azure.com/$fakeOrgName/_apis/accesscontrollists/$fakeSecurityNamespaceID?api-version=$fakeApiVersion"
            $actualBody = $fakeSerializedACLs | ConvertTo-Json -Depth 4

            # Assert the Invoke-AzDevOpsApiRestMethod was called with the expected parameters
            Assert-MockCalled -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It
            $lastCommand = (Get-MockCalled -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod).ParameterSet
            $lastCommand.Uri | Should -Be $actualUri
            $lastCommand.Method | Should -Be "POST"
            $lastCommand.Body | Should -Be $actualBody
        }

        It "Should default ApiVersion if not provided" {
            Set-xAzDoPermission -OrganizationName $fakeOrgName -SecurityNamespaceID $fakeSecurityNamespaceID -SerializedACLs $fakeSerializedACLs

            Mock -Assert -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod { Param ([string]$Uri, [string]$Method, [string]$Body)}

            $defaultApiVersion = "5.1-preview.1"
            $actualUri = "https://dev.azure.com/$fakeOrgName/_apis/accesscontrollists/$fakeSecurityNamespaceID?api-version=$defaultApiVersion"
            $actualBody = $fakeSerializedACLs | ConvertTo-Json -Depth 4

            # Assert the Invoke-AzDevOpsApiRestMethod was called with the expected parameters
            Assert-MockCalled -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It
            $lastCommand = (Get-MockCalled -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod).ParameterSet
            $lastCommand.Uri | Should -Be $actualUri
            $lastCommand.Method | Should -Be "POST"
            $lastCommand.Body | Should -Be $actualBody
        }
    }

    Context "When an error occurs" {
        It "Should write an error message" {

            Mock -ModuleName YourModule -FunctionName Invoke-AzDevOpsApiRestMethod {
                throw "Test Exception"
            }

            { Set-xAzDoPermission -OrganizationName $fakeOrgName -SecurityNamespaceID $fakeSecurityNamespaceID -SerializedACLs $fakeSerializedACLs -ApiVersion $fakeApiVersion } | Should -Throw

            # Check error was written to the output
            $error[0].Exception.Message | Should -Be "Test Exception"
        }
    }
}

