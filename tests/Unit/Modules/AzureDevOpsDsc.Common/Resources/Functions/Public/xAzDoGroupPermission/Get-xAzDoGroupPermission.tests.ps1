$currentFile = $MyInvocation.MyCommand.Path


# Tests are currently disabled.
Describe 'Get-xAzDoGroupPermission' -skip {

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

            switch ($Type) {
                'LiveGroups' {
                    return @{
                        id = 'mockOriginId'
                        name = 'mockOriginName'
                    }
                }
                'LiveProjects' {
                    return @{
                        id = 'mockProjectId'
                        name = 'mockProjectName'
                    }
                }
                'SecurityNamespaces' {
                    return @{
                        namespaceId = 'mockSecurityNamespaceId'
                        name = 'mockSecurityNamespaceName'
                    }
                }
            }
        }


        Mock -CommandName Get-DevOpsACL -MockWith {
            return @(
                @{
                    Token = @{
                        Type     = 'GroupPermission'
                        GroupId  = 'mockOriginId'
                        ProjectId= 'mockProjectId'
                    }
                }
            )
        }

        Mock -CommandName ConvertTo-FormattedACL -MockWith {
            return @(
                @{
                    Token = @{
                        Type     = 'GroupPermission'
                        GroupId  = 'mockOriginId'
                        ProjectId= 'mockProjectId'
                    }
                }
            )
        }

        Mock -CommandName ConvertTo-ACL -MockWith {
            return @{
                aces = @{
                    Count = 1
                }
                token = @{
                    Type = 'GroupPermission'
                }
            }
        }

        Mock -CommandName Test-ACLListforChanges -MockWith {
            return @{
                propertiesChanged = @('property1', 'property2')
                status = 'Compliant'
                reason = 'No changes detected'
            }
        }

        Mock -CommandName Write-Warning

    }

    It 'Should return group result with correct properties when valid GroupName is provided' {

        $result = Get-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true
        Wait-Debugger

        $result | Should -Not -BeNullOrEmpty
        $result.project | Should -Be 'Project'
        $result.groupName | Should -Be 'Group'
        $result.propertiesChanged | Should -Contain 'property1'
        $result.status | Should -Be 'Unchanged'

    }

    It 'Should not throw an error when GroupName is invalid' {
        $result = Get-xAzDoGroupPermission -GroupName 'InvalidGroupName' -isInherited $true
        $result | Should -BeNullOrEmpty
    }

    It 'Should return null when no ACEs found for the group' {
        Mock -CommandName 'ConvertTo-ACL' -MockWith {
            param ($Permissions, $SecurityNamespace, $isInherited, $OrganizationName, $TokenName)
            return @{
                aces = @{
                    Count = 0
                }
            }
        }

        $result = Get-xAzDoGroupPermission -GroupName 'Project\Group' -isInherited $true
        $result | Should -BeNullOrEmpty
    }
}
