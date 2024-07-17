powershell
Describe 'Remove-xAzDoPermission' {

    Mock Get-AzDevOpsApiVersion { return "5.1-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod { return $true }

    Context 'When parameters are valid' {

        It 'should invoke REST method to remove ACLs successfully' {
            $OrganizationName = 'Org'
            $SecurityNamespaceID = 'NamespaceID'
            $TokenName = 'Token'
            $ApiVersion = '5.1-preview.1'

            { Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName -ApiVersion $ApiVersion } | Should -Not -Throw
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq 'https://dev.azure.com/Org/_apis/accesscontrollists/NamespaceID?tokens=Token&recurse=False&api-version=5.1-preview.1' -and
                $Method -eq 'DELETE'
            }
        }
    }

    Context 'When Invoke-AzDevOpsApiRestMethod returns false' {
        Mock Invoke-AzDevOpsApiRestMethod { return $false }

        It 'should write an error message stating failed to remove ACLs' {
            $OrganizationName = 'Org'
            $SecurityNamespaceID = 'NamespaceID'
            $TokenName = 'Token'

            { Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName } | Should -Throw | Should -Contain '[Remove-xAzDoPermission] Failed to remove ACLs.'
        }
    }

    Context 'When an exception occurs' {
        Mock Invoke-AzDevOpsApiRestMethod { throw 'An error occurred' }

        It 'should write an error message with the exception details' {
            $OrganizationName = 'Org'
            $SecurityNamespaceID = 'NamespaceID'
            $TokenName = 'Token'

            { Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName } | Should -Throw | Should -Contain '[Remove-xAzDoPermission] Failed to add member to group: An error occurred'
        }
    }
}

