powershell
# Define the function
function Get-DevOpsDescriptorIdentity {
    # Function code as described above
}

# Test the function
Describe 'Get-DevOpsDescriptorIdentity Tests' {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview.1' }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    Context 'When retrieving identity by SubjectDescriptor' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $orgName = "MyOrg"
            $subjectDescriptor = "subject:abcd1234"
            $expectedUri = "https://vssps.dev.azure.com/$orgName/_apis/identities?subjectDescriptors=$subjectDescriptor&api-version=6.0-preview.1"

            Get-DevOpsDescriptorIdentity -OrganizationName $orgName -SubjectDescriptor $subjectDescriptor

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -Parameters @{
                Uri = $expectedUri
                Method = 'Get'
            }
        }
    }

    Context 'When retrieving identity by Descriptor' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $orgName = "MyOrg"
            $descriptor = "descriptor:abcd1234"
            $expectedUri = "https://vssps.dev.azure.com/$orgName/_apis/identities?descriptors=$descriptor&api-version=6.0-preview.1"

            Get-DevOpsDescriptorIdentity -OrganizationName $orgName -Descriptor $descriptor

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -Parameters @{
                Uri = $expectedUri
                Method = 'Get'
            }
        }
    }

    Context 'When result has multiple identities' {
        It 'Should return $null' {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { @{
                count = 2
                value = @('identity1', 'identity2')
            } }

            $result = Get-DevOpsDescriptorIdentity -OrganizationName "MyOrg" -SubjectDescriptor "subject:abcd1234"
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When result has no identity' {
        It 'Should return $null' {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { @{ count = 0 } }

            $result = Get-DevOpsDescriptorIdentity -OrganizationName "MyOrg" -SubjectDescriptor "subject:abcd1234"
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When result has one identity' {
        It 'Should return the identity' {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                @{
                    count = 1
                    value = @('identity1')
                }
            }

            $result = Get-DevOpsDescriptorIdentity -OrganizationName "MyOrg" -SubjectDescriptor "subject:abcd1234"
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeExactly 'identity1'
        }
    }
}

