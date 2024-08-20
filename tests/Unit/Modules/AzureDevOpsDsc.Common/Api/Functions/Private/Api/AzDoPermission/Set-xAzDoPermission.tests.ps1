$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-xAzDoPermission Tests' {

    BeforeAll {
        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion { return '6.0-preview.1' }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod { return $null }

        $OrganizationName = "TestOrg"
        $SecurityNamespaceID = "TestNamespace"
        $SerializedACLs = @{some = "data"}
        $ApiVersion = "5.0"

    }


    Context 'When Mandatory Parameters are provided' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $expectedUri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}" -f $OrganizationName, $SecurityNamespaceID, $ApiVersion

            Set-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -SerializedACLs $SerializedACLs -ApiVersion $ApiVersion

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $params.Uri -eq $expectedUri -and
                $params.Method -eq 'POST' -and
                $params.Body -eq ($SerializedACLs | ConvertTo-Json -Depth 4)
            }
        }
    }

    Context 'When ApiVersion is not provided' {
        It 'Should call ExampleFunction and get default ApiVersion' {
            $expectedUri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}" -f $OrganizationName, $SecurityNamespaceID, "6.0-preview.1"

            Set-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -SerializedACLs $SerializedACLs

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $params.Uri -eq $expectedUri -and
                $params.Method -eq 'POST' -and
                $params.Body -eq ($SerializedACLs | ConvertTo-Json -Depth 4)
            }
        }
    }

    Context 'When an exception occurs' {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod { throw "API call failed" }

        It 'Should catch and log the error' {
            $ErrorActionPreference = 'Stop'

            { Set-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -SerializedACLs $SerializedACLs -ApiVersion $ApiVersion } | Should -Throw

            Assert-MockCalled -CommandName Write-Error -Exactly -Times 1 -Scope It
            Assert-MockCalled -CommandName Write-Error -ParameterFilter {
                $Message -match '\[Set-xAzDoPermission\] Failed to set ACLs:'
            }
        }
    }
}


