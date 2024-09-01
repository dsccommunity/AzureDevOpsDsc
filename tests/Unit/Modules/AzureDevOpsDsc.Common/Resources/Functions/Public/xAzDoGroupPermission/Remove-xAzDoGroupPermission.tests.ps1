$currentFile = $MyInvocation.MyCommand.Path

# Tests are currently disabled.
Describe 'Remove-xAzDoGroupPermission' -skip {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-xAzDoGroupMember.tests.ps1'
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


        # Mock dependencies
        Mock -CommandName Get-CacheItem -MockWith {
            param ($Key, $Type)
            switch ($Type) {
                'SecurityNamespaces' { return @{ namespaceId = 'mockNamespaceId' } }
                'LiveProjects' { return @{ id = 'mockProjectId' } }
                'LiveRepositories' { return @{ id = 'mockRepositoryId' } }
                'LiveACLList' { return @(
                    @{ token = 'repoV2/mockProjectId/mockRepositoryId' },
                    @{ token = 'repoV2/anotherProject/anotherRepo' }
                ) }
                default { return $null }
            }
        }

        Mock -CommandName Remove-xAzDoPermission -MockWith {}

    }

    It 'Should remove permissions when valid GroupName is provided' {
        Remove-xAzDoGroupPermission -GroupName 'Project\Repository' -isInherited $true -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Identity'; Type = 'SecurityNamespaces' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Project'; Type = 'LiveProjects' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Project\Repository'; Type = 'LiveRepositories' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'mockNamespaceId'; Type = 'LiveACLList' } -Times 1
        Assert-MockCalled -CommandName Remove-xAzDoPermission -Times 1
    }

    It 'Should throw a warning when GroupName is invalid' {
        { Remove-xAzDoGroupPermission -GroupName 'InvalidGroupName' -isInherited $true } | Should -Throw
    }

    It 'Should handle case where no matching ACLs are found' {
        Mock -CommandName Get-CacheItem -MockWith {
            param ($Key, $Type)
            if ($Type -eq 'LiveACLList') {
                return @(
                    @{ token = 'repoV2/anotherProject/anotherRepo' }
                )
            }
            return @{
                namespaceId = 'mockNamespaceId',
                id          = 'mockProjectId'
            }
        }

        Remove-xAzDoGroupPermission -GroupName 'Project\Repository' -isInherited $true -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Remove-xAzDoPermission -Times 0
    }

    It 'Should not call Remove-xAzDoPermission if no ACLs are found' {
        Mock -CommandName Get-CacheItem -MockWith {
            param ($Key, $Type)
            if ($Type -eq 'LiveACLList') {
                return @()
            }
            return @{
                namespaceId = 'mockNamespaceId',
                id          = 'mockProjectId'
            }
        }

        Remove-xAzDoGroupPermission -GroupName 'Project\Repository' -isInherited $true -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Remove-xAzDoPermission -Times 0
    }
}
