powershell
Describe 'Get-DevOpsACL' {
    Param (
        [string]$OrganizationName = 'TestOrg',
        [string]$SecurityDescriptorId = 'TestId',
        [string]$ApiVersion = '5.1-preview.1'
    )

    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '5.1-preview.1' }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
        return @{ value = @("ACL1", "ACL2"); count = 2 }
    }
    Mock -CommandName Add-CacheItem
    Mock -CommandName Export-CacheObject

    Context 'When ACL List is retrieved successfully' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/$OrganizationName/_apis/accesscontrollists/$SecurityDescriptorId?api-version=$ApiVersion" -and
                $Method -eq 'Get'
            }
        }

        It 'Should cache the ACL List' {
            Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            Assert-MockCalled -CommandName Add-CacheItem -Exactly 1
            Assert-MockCalled -CommandName Export-CacheObject -Exactly 1
        }

        It 'Should return ACL List' {
            $result = Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            $result | Should -Be @("ACL1", "ACL2")
        }
    }

    Context 'When ACL List is empty' {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ value = @(); count = 0 }
        }

        It 'Should return $null' {
            $result = Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            $result | Should -BeNullOrEmpty
        }

        It 'Should not cache the ACL List' {
            Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            Assert-MockNotCalled -CommandName Add-CacheItem
            Assert-MockNotCalled -CommandName Export-CacheObject
        }
    }

    Context 'When ACL List is $null' {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ value = $null; count = 0 }
        }

        It 'Should return $null' {
            $result = Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            $result | Should -BeNullOrEmpty
        }

        It 'Should not cache the ACL List' {
            Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId

            Assert-MockNotCalled -CommandName Add-CacheItem
            Assert-MockNotCalled -CommandName Export-CacheObject
        }
    }
}

