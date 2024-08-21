$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-xAzDoPermission Tests' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-xAzDoPermission.tests.ps1'
        }

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

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq $expectedUri
                $Method -eq 'POST'
                $Body -eq $SerializedACLs
            }
        }
    }

    Context 'When ApiVersion is not provided' {
        It 'Should call ExampleFunction and get default ApiVersion' {
            $expectedUri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}" -f $OrganizationName, $SecurityNamespaceID, "6.0-preview.1"

            Set-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -SerializedACLs $SerializedACLs

            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly 1
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq $expectedUri
                $Method -eq 'POST'
                $Body -eq $SerializedACLs
            }
        }
    }

    Context 'When an exception occurs' {

        It 'Should catch and log the error' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod { throw "API call failed" }
            Mock -CommandName Write-Error

            $result = Set-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -SerializedACLs $SerializedACLs -ApiVersion $ApiVersion

            $result | Should -BeNullOrEmpty
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1
            Assert-MockCalled -CommandName Write-Error -Exactly -Times 1

        }
    }
}


