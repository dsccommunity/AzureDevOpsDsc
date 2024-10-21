$currentFile = $MyInvocation.MyCommand.Path

# Tests are currently disabled.
Describe 'Set-AzDoGroupPermission' -skip {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzDoGroupPermission.tests.ps1'
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
            param (
                [string]$Key,
                [string]$Type
            )
            switch ($Type)
            {
                'SecurityNamespaces' {
                    return @{ namespaceId = 'mockNamespaceId' }
                }
                'LiveProjects' {
                    return @{ id = 'mockProjectId' }
                }
                'LiveACLList' {
                    return @(
                        @{ token = 'repoV2/mockProjectId/mockRepositoryId' },
                        @{ token = 'repoV2/anotherProject/anotherRepo' }
                    )
                }
                default {
                    return $null
                }
            }
        }

        Mock -CommandName ConvertTo-ACLHashtable -MockWith {
            param (
                [HashTable]$ReferenceACLs,
                [Array]$DescriptorACLList,
                [string]$DescriptorMatchToken
            )
            return @{ serializedACLs = 'mockSerializedACLs' }
        }

        Mock -CommandName Set-AzDoPermission

    }

    It 'Should throw a warning when GroupName is invalid' {
        { Set-AzDoGroupPermission -GroupName 'InvalidGroupName' -isInherited $true } | Should -Throw
    }

    It 'Should set permissions when valid GroupName is provided' {
        $LookupResult = @{
            propertiesChanged = @{}
        }

        Set-AzDoGroupPermission -GroupName 'Project\Repository' -isInherited $true -Permissions @{} -LookupResult $LookupResult -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Get-CacheItem -Exactly -Times 1 -Scope It -ParameterFilter {
            $Key -eq 'Identity' -and $Type -eq 'SecurityNamespaces'
        }
        Assert-MockCalled -CommandName Get-CacheItem -Exactly -Times 1 -Scope It -ParameterFilter {
            $Key -eq $ProjectName -and $Type -eq 'LiveProjects'
        }
        Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Exactly -Times 1 -Scope It
        Assert-MockCalled -CommandName Set-AzDoPermission -Exactly -Times 1 -Scope It
    }

    It 'Should call ConvertTo-ACLHashtable with correct parameters' {
        $LookupResult = @{
            propertiesChanged = @{}
        }

        Set-AzDoGroupPermission -GroupName 'Project\Repository' -isInherited $true -Permissions @{} -LookupResult $LookupResult -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Exactly -Times 1 -Scope It -ParameterFilter {
            $ReferenceACLs -eq $LookupResult.propertiesChanged -and
            $DescriptorACLList -eq (Get-CacheItem -Key 'mockNamespaceId' -Type 'LiveACLList') -and
            $DescriptorMatchToken -eq ('repoV2/mockProjectId/mockRepositoryId')
        }
    }

    It 'Should not call Set-AzDoPermission if no ACLs are found' {
        Mock -CommandName Get-CacheItem -MockWith {
            param (
                [string]$Key,
                [string]$Type
            )
            if ($Type -eq 'LiveACLList') {
                return @()
            }
            return @{
                namespaceId = 'mockNamespaceId'
                id          = 'mockProjectId'
            }
        }

        $LookupResult = @{
            propertiesChanged = @{}
        }

        Set-AzDoGroupPermission -GroupName 'Project\Repository' -isInherited $true -Permissions @{} -LookupResult $LookupResult -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Set-AzDoPermission -Exactly -Times 0 -Scope It
    }
}
