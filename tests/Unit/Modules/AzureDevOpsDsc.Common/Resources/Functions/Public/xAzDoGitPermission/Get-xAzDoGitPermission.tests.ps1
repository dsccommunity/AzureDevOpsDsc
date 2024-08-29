$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-xAzDoGitPermission Tests' {

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')

        Function Mock-Get-CacheItem {
            param (
                [string]$Key,
                [string]$Type
            )
            switch ($Type) {
                'LiveRepositories' { return @{ id = 123; Name = "TestRepository" } }
                'SecurityNamespaces' { return @{ namespaceId = "TestNamespaceId" } }
                default { return $null }
            }
        }

        Function Mock-Get-DevOpsACL {
            param (
                [Parameter(Mandatory)]
                [string]$OrganizationName,
                [Parameter(Mandatory)]
                [string]$SecurityDescriptorId
            )
            return @( @{ Token = @{ Type = 'GitRepository'; RepoId = 123 }; Permission = 'Allow' } )
        }

        Function Mock-ConvertTo-FormattedACL {
            param (
                [Parameter(Mandatory)]
                $SecurityNamespace,
                [Parameter(Mandatory)]
                $OrganizationName
            )
            return @( @{ Token = @{ Type = 'GitRepository'; RepoId = 123 }; Permission = 'Allow' } )
        }

        Function Mock-ConvertTo-ACL {
            param (
                [Parameter(Mandatory)]
                $Permissions,
                [Parameter(Mandatory)]
                $SecurityNamespace,
                [Parameter(Mandatory)]
                $isInherited,
                [Parameter(Mandatory)]
                $OrganizationName,
                [Parameter(Mandatory)]
                $TokenName
            )
            return @( @{ Token = @{ Type = 'GitRepository'; RepoId = 123 }; Permission = 'Deny' } )
        }

        Function Mock-Test-ACLListforChanges {
            param (
                [Parameter(Mandatory)]
                $ReferenceACLs,
                [Parameter(Mandatory)]
                $DifferenceACLs
            )
            return @{
                propertiesChanged = @('Permission');
                status = 'Changed';
                reason = 'Permission mismatch'
            }
        }

        Mock -CommandName Write-Verbose
        Mock -CommandName Write-Warning
        Mock -CommandName Get-CacheItem -MockWith { Mock-Get-CacheItem -Key $Key -Type $Type }
        Mock -CommandName Get-DevOpsACL -MockWith { Mock-Get-DevOpsACL -OrganizationName $OrganizationName -SecurityDescriptorId $SecurityDescriptorId }
        Mock -CommandName ConvertTo-FormattedACL -MockWith { Mock-ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName }
        Mock -CommandName ConvertTo-ACL -MockWith { Mock-ConvertTo-ACL -Permissions $Permissions -SecurityNamespace $SecurityNamespace -isInherited $isInherited -OrganizationName $OrganizationName -TokenName $TokenName }
        Mock -CommandName Test-ACLListforChanges -MockWith { Mock-Test-ACLListforChanges -ReferenceACLs $ReferenceACLs -DifferenceACLs $DifferenceACLs }
    }

    It 'Should retrieve repository and namespace, and compare ACLs correctly' {
        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = 'Deny' })

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'Changed'
        $result.propertiesChanged | Should -Contain 'Permission'
    }

    It "Should return 'Unchanged' if the permissions are the same" {
        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = 'Allow' })

        Mock -CommandName Test-ACLListforChanges -MockWith {
            return @{
                propertiesChanged = @()
                status = 'Unchanged'
                reason = 'No change'
            }
        }

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'Unchanged'
        $result.propertiesChanged | Should -BeNullOrEmpty
    }

    It "Should returned 'Changed' if one of the permissions is null" {
        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = $null })

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'Changed'
        $result.propertiesChanged | Should -Contain 'Permission'
    }

    It "Should return 'NotFound' if the repository is not found" {

        Mock -CommandName Get-CacheItem -MockWith { return $null } -ParameterFilter { $Type -eq 'LiveRepositories' }

        $ProjectName = 'TestProject'
        $RepositoryName = 'NotFoundRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = 'Allow' })

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'NotFound'
        $result.propertiesChanged | Should -BeNullOrEmpty
    }

    It "Should return 'NotFound' if Get-DevOpsACL is null" {
        Mock -CommandName Get-DevOpsACL -MockWith { return $null }
        Mock -CommandName Write-Warning -Verifiable

        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = 'Allow' })

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'NotFound'
        Assert-VerifiableMock
    }

    It "Should return 'NotFound' if ConvertTo-FormattedACL is null" {
        Mock -CommandName ConvertTo-FormattedACL -MockWith { return $null }
        Mock -CommandName Write-Warning -Verifiable

        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepository'
        $isInherited = $true
        $Permissions = @(@{ 'Permission' = 'Allow' })

        $result = Get-xAzDoGitPermission -ProjectName $ProjectName -RepositoryName $RepositoryName -isInherited $isInherited -Permissions $Permissions

        $result | Should -Not -BeNullOrEmpty
        $result.status | Should -Be 'NotFound'
        Assert-VerifiableMock
    }

}
