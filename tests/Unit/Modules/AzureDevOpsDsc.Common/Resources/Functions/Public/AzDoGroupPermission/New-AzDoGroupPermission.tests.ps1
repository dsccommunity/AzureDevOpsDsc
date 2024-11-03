$currentFile = $MyInvocation.MyCommand.Path

# Resource is currently disabled
Describe 'New-AzDoGroupPermission' -skip {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzDoGroupMember.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)

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
            switch ($Type)
            {
                'SecurityNamespaces' {
                    return @{ namespaceId = 'mockNamespaceId' }
                }
                'LiveProjects' {
                    return @{ id = 'mockProjectId' }
                }
                'LiveGroups' {
                    return @{ id = 'mockGroupId' }
                }
                'LiveACLList' {
                    return @{}
                }
                default {
                    return $null
                }
            }
        }

        Mock -CommandName ConvertTo-ACLHashtable -MockWith {
            param ($ReferenceACLs, $DescriptorACLList, $DescriptorMatchToken)
            return @{
                aces = @{
                    Count = 1
                }
            }
        }

        Mock -CommandName Set-AzDoPermission

    }

    It 'Should set permissions when valid GroupName is provided' {
        $LookupResult = @{
            propertiesChanged = @('property1', 'property2')
        }
        $Permissions = @(
            @{
                PermissionBit = 'Read'
                DisplayName = 'Read'
            }
        )

        New-AzDoGroupPermission -GroupName 'Project\Group' -isInherited $true -Permissions $Permissions -LookupResult $LookupResult -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Identity'; Type = 'SecurityNamespaces' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Project'; Type = 'LiveProjects' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = '[Project]\Group'; Type = 'LiveGroups' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'mockNamespaceId'; Type = 'LiveACLList' } -Times 1
        Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Times 1
        Assert-MockCalled -CommandName Set-AzDoPermission -Times 1
    }

    It 'Should throw a warning when GroupName is invalid' {
        { New-AzDoGroupPermission -GroupName 'InvalidGroupName' -isInherited $true } | Should -Throw
    }

    It 'Should handle case where no LookupResult is provided' {
        $result = New-AzDoGroupPermission -GroupName 'Project\Group' -isInherited $true -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Identity'; Type = 'SecurityNamespaces' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'Project'; Type = 'LiveProjects' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = '[Project]\Group'; Type = 'LiveGroups' } -Times 1
        Assert-MockCalled -CommandName Get-CacheItem -Parameters @{ Key = 'mockNamespaceId'; Type = 'LiveACLList' } -Times 1
        Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Times 1
        Assert-MockCalled -CommandName Set-AzDoPermission -Times 1
    }

    It 'Should not call Set-AzDoPermission if no ACLs are found' {
        Mock -CommandName ConvertTo-ACLHashtable -MockWith {
            return @{
                aces = @{
                    Count = 0
                }
            }
        }

        $LookupResult = @{
            propertiesChanged = @('property1', 'property2')
        }

        New-AzDoGroupPermission -GroupName 'Project\Group' -isInherited $true -LookupResult $LookupResult -Ensure 'Present' -Force:$true

        Assert-MockCalled -CommandName Set-AzDoPermission -Times 0
    }
}
