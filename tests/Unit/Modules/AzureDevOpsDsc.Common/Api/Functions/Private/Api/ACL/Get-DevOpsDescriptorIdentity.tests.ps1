
Import-Module Pester

Describe 'Get-DevOpsDescriptorIdentity' {
    $OrganizationName = "MyOrg"
    $SubjectDescriptor = "subject:abcd1234"
    $Descriptor = "descriptor:abcd1234"
    $ApiVersion = "5.0"

    Mock Get-AzDevOpsApiVersion { return "5.0" }
    Mock Invoke-AzDevOpsApiRestMethod

    Context 'With Default Parameter Set and SubjectDescriptor' {
        It 'Calls Invoke-AzDevOpsApiRestMethod with correct parameters' {
            Get-DevOpsDescriptorIdentity -OrganizationName $OrganizationName -SubjectDescriptor $SubjectDescriptor

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -match "subjectDescriptors=$SubjectDescriptor" -and
                $Uri -match "_apis/identities" -and
                $Method -eq 'Get'
            }
        }
    }

    Context 'With Descriptors Parameter Set' {
        It 'Calls Invoke-AzDevOpsApiRestMethod with correct parameters' {
            Get-DevOpsDescriptorIdentity -OrganizationName $OrganizationName -Descriptor $Descriptor

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -match "descriptors=$Descriptor" -and
                $Uri -match "_apis/identities" -and
                $Method -eq 'Get'
            }
        }
    }

    Context 'Handles empty response' {
        It 'Returns $null when identity value is $null' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ value = $null; count = 0 } }

            $result = Get-DevOpsDescriptorIdentity -OrganizationName $OrganizationName -SubjectDescriptor $SubjectDescriptor

            $result | Should -BeNullOrEmpty
        }

        It 'Returns $null when count is greater than 1' {
            Mock Invoke-AzDevOpsApiRestMethod { return @{ value = @('identity1', 'identity2'); count = 2 } }

            $result = Get-DevOpsDescriptorIdentity -OrganizationName $OrganizationName -SubjectDescriptor $SubjectDescriptor

            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Handles valid response' {
        It 'Returns identity value when count is 1' {
            $expectedValue = @('identity1')
            Mock Invoke-AzDevOpsApiRestMethod { return @{ value = $expectedValue; count = 1 } }

            $result = Get-DevOpsDescriptorIdentity -OrganizationName $OrganizationName -SubjectDescriptor $SubjectDescriptor

            $result | Should -Be $expectedValue
        }
    }
}

