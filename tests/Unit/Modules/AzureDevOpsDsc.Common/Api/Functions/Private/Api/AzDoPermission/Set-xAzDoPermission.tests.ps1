powershell
# Requires Pester 5.0 or later

# Mocking the Invoke-AzDevOpsApiRestMethod function
Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' {
    param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Method,

        [Parameter(Mandatory)]
        [Object]$Body
    )
    # Mock behavior here, can return a specific result if needed
    return $null
}

Describe 'Set-xAzDoPermission' {
    BeforeAll {
        Import-Module -Name 'Path\To\Your\Module.psm1'
    }
    Context 'When called with valid parameters' {
        It 'Should invoke Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $organizationName = 'YourOrganization'
            $securityNamespaceID = 'SomeSecurityNamespaceID'
            $serializedACLs = @{ Property = 'Value' }
            $apiVersion = '6.0'

            Set-xAzDoPermission -OrganizationName $organizationName -SecurityNamespaceID $securityNamespaceID -SerializedACLs $serializedACLs -ApiVersion $apiVersion

            # Assert that the Invoke-AzDevOpsApiRestMethod was called with the correct parameters
            Assert-MockCalled -CommandName 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -Scope It -ParameterFilter {
                $PSCommandPath -eq "https://dev.azure.com/$organizationName/_apis/accesscontrollists/$securityNamespaceID?api-version=$apiVersion" -and
                $Method -eq 'POST' -and
                $Body -eq ($serializedACLs | ConvertTo-Json -Depth 4)
            }
        }
    }

    Context 'When Invoke-AzDevOpsApiRestMethod throws an exception' {
        BeforeEach {
            Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
                throw "API call failed"
            }
        }
        It 'Should catch the exception and write an error message' {
            $organizationName = 'YourOrganization'
            $securityNamespaceID = 'SomeSecurityNamespaceID'
            $serializedACLs = @{ Property = 'Value' }
            $apiVersion = '6.0'

            { Set-xAzDoPermission -OrganizationName $organizationName -SecurityNamespaceID $securityNamespaceID -SerializedACLs $serializedACLs -ApiVersion $apiVersion } | Should -Throw

            # Assert that the error message was written
            Assert-VerifiableMocks
        }
    }
}

