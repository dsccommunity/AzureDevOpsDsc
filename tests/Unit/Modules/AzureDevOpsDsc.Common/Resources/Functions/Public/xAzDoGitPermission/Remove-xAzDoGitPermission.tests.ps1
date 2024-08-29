$currentFile = $MyInvocation.MyCommand.Path

Describe "Remove-xAzDoGitPermission" {


    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-xAzDoGitPermission.tests.ps1'
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

        Mock -CommandName Remove-xAzDoPermission
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

    #TODO: Add more tests

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

        Remove-xAzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-xAzDoPermission -Times 1
        Assert-VerifiableMock

    }

    It "Does not call Remove-GitRepositoryPermission if Filtered is null" {

        Mock -Name 'Get-CacheItem' -MockWith {
            switch ($Type) {
                'LiveACLList' { @(@{ token = 'repoV2/notMatchingValue' }) }
                default { $null }
            }
        }

        Remove-xAzDoGitPermission @params

        Assert-MockCalled -CommandName Remove-xAzDoPermission -Exactly 0
        Assert-VerifiableMock

    }
}
