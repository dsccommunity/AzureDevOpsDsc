$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-DevOpsACL" -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-DevOpsACL.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mock the required functions
        Mock -CommandName Get-AzDevOpsApiVersion { return "6.0" }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod
        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    It "should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
        $orgName = "TestOrg"
        $secDescId = "abc123"
        $apiVersion = "6.0"

        Get-DevOpsACL -OrganizationName $orgName -SecurityDescriptorId $secDescId

        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://dev.azure.com/$orgName/_apis/accesscontrollists/$secDescId?api-version=$apiVersion"
            $Method -eq "GET"
        }
    }

    It "should handle null response from REST API and return null" {
        Mock Invoke-AzDevOpsApiRestMethod { return @{ value = $null } }

        $result = Get-DevOpsACL -OrganizationName "TestOrg" -SecurityDescriptorId "abc123"

        $result | Should -BeNull
        Assert-MockCalled Add-CacheItem -Times 0 -Exactly -Scope It
        Assert-MockCalled Export-CacheObject -Times 0 -Exactly -Scope It

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

