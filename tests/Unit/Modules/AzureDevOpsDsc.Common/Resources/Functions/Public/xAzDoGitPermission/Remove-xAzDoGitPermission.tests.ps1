$currentFile = $MyInvocation.MyCommand.Path

Describe "Remove-AzDoGitPermission" {


    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-AzDoGitPermission.tests.ps1'
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
        . (Get-ClassFilePath '002.LocalizedDataAzSerializationPatten')

        Mock -CommandName Remove-AzDoPermission
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type)
            {
                'SecurityNamespaces' { @{ namespaceId = 'namespaceIdValue' } }
                'LiveProjects' { @{ id = 'projectIdValue' } }
                'LiveRepositories' { @{ id = 'repositoryIdValue' } }
                'LiveACLList' { @(@{ token = 'repoV2/projectIdValue/repositoryIdValue' }) }
                default { $null }
            }
        }

        $Global:DSCAZDO_OrganizationName = 'TestOrg'

    }

    BeforeEach {

        $params = @{
            ProjectName = 'TestProject'
            RepositoryName = 'TestRepo'
            isInherited = $false
            Permissions = @()
            LookupResult = @{}
            Ensure = 'Present'
            Force = $false
        }

    }

    It "Removes ACLs if Filtered is not null" {

        Mock -CommandName 'Write-Verbose' -Verifiable

        Remove-AzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-AzDoPermission -Times 1
        Assert-VerifiableMock

    }

    It "Does not call Remove-GitRepositoryPermission if Filtered is null" {

        Mock -CommandName Write-Error -Verifiable
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type) {
                'LiveACLList' { @(@{ token = 'repoV2/notMatchingValue' }) }
                default { $null }
            }
        }

        Remove-AzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-AzDoPermission -Exactly 0
        Assert-VerifiableMock

    }

    It "Does not call Remove-GitRepositoryPermission if ACLs are null" {

        Mock -CommandName Write-Error -Verifiable
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type) {
                'LiveACLList' { $null }
                default { $null }
            }
        }

        Remove-AzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-AzDoPermission -Exactly 0
        Assert-VerifiableMock

    }

    It "Does not call Remove-GitRepositoryPermission if Repository is null" {

        Mock -CommandName Write-Error -Verifiable
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type) {
                'LiveRepositories' { $null }
                default { $null }
            }
        }

        Remove-AzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-AzDoPermission -Exactly 0
        Assert-VerifiableMock

    }

    It "Does not call Remove-GitRepositoryPermission if Project is null" {

        Mock -CommandName Write-Error -Verifiable
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type) {
                'LiveProjects' { $null }
                default { $null }
            }
        }

        Remove-AzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-AzDoPermission -Exactly 0
        Assert-VerifiableMock

    }

    It "Does not call Remove-GitRepositoryPermission if SecurityNamespace is null" {

        Mock -CommandName Write-Error -Verifiable
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type) {
                'SecurityNamespaces' { $null }
                default { $null }
            }
        }

        Remove-AzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-AzDoPermission -Exactly 0
        Assert-VerifiableMock

    }

}
