ps1
Describe "Get-DevOpsACL" {
    Mock Get-AzDevOpsApiVersion { return "6.0" }
    Mock Invoke-AzDevOpsApiRestMethod
    Mock Add-CacheItem
    Mock Export-CacheObject
    
    BeforeEach {
        Clear-Host
    }

    It "should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
        $orgName = "TestOrg"
        $secDescId = "abc123"
        $apiVersion = "6.0"

        Get-DevOpsACL -OrganizationName $orgName -SecurityDescriptorId $secDescId

        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -ParameterFilter {
            $params.Uri -eq "https://dev.azure.com/TestOrg/_apis/accesscontrollists/abc123?api-version=6.0" -and
            $params.Method -eq 'Get'
        }
    }

    It "should handle null response from REST API and return null" {
        Mock Invoke-AzDevOpsApiRestMethod { return @{ value = $null } }
        
        $result = Get-DevOpsACL -OrganizationName "TestOrg" -SecurityDescriptorId "abc123"

        $result | Should -BeNull
        Assert-MockNotCalled Add-CacheItem
        Assert-MockNotCalled Export-CacheObject
    }

    It "should cache and return ACL list if response is not empty" {
        $mockACLList = @{ count = 1; value = @("aclEntry1", "aclEntry2") }

        Mock Invoke-AzDevOpsApiRestMethod { return $mockACLList }
        
        $result = Get-DevOpsACL -OrganizationName "TestOrg" -SecurityDescriptorId "abc123"

        $result | Should -HaveCount 2
        Assert-MockCalled Add-CacheItem -Times 1 -Exactly -Scope It
        Assert-MockCalled Export-CacheObject -Times 1 -Exactly -Scope It
    }
}

