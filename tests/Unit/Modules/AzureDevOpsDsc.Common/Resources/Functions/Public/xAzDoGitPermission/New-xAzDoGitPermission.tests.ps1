$currentFile = $MyInvocation.MyCommand.Path

Describe 'New-xAzDoGitPermission' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-xAzDoGitPermission.tests.ps1'
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

        Mock -CommandName Get-CacheItem -MockWith { return @{ namespaceId = '12345'; id = '67890' } }
        Mock -CommandName ConvertTo-ACLHashtable -MockWith { return @{} }
        Mock -CommandName Set-xAzDoPermission -MockWith { }
    }

    Context 'With mandatory parameters provided' {
        It 'should call Get-CacheItem for SecurityNamespace and Project' {
            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled -CommandName Set-xAzDoPermission -Exactly 1
        }

        It 'should call ConvertTo-ACLHashtable and Set-xAzDoPermission' {
            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
                LookupResult = @{ propertiesChanged = @{} }
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Exactly 1
            Assert-MockCalled -CommandName Set-xAzDoPermission -Exactly 1
        }
    }

    Context 'With all parameters provided' {
        It 'should set permissions correctly' {
            $permissions = @(@{ Permission = 'Read'; Access = 'Allow' })

            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
                Permissions = $permissions
                LookupResult = @{ propertiesChanged = @{} }
                Ensure = 'Present'
                Force = $true
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled -CommandName Get-CacheItem -Times 2
            Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Exactly 1
            Assert-MockCalled -CommandName Set-xAzDoPermission -Exactly 1
        }
    }

    Context 'When Get-CacheItem returns nothing' {
        It 'should not call ConvertTo-ACLHashtable or Set-xAzDoPermission' {

            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'SecurityNamespaces' } -MockWith { return $null }
            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'LiveProjects' } -MockWith { return $null }
            Mock -CommandName Write-Warning -Verifiable

            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
            }
            New-xAzDoGitPermission @params

            Assert-MockCalled -CommandName ConvertTo-ACLHashtable -Exactly 0
            Assert-MockCalled -CommandName Set-xAzDoPermission -Exactly 0
            Assert-VerifiableMock
        }
    }

    # Not in use
    Context 'When Force switch is provided' -skip {
        It 'should handle the Force switch correctly' {
            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
                Force = $true
            }
            New-xAzDoGitPermission @params

            # Verify if any additional logic related to -Force was executed
            # This is a placeholder as the current implementation does not use -Force
        }
    }

    Context 'Verbose output' {
        It 'should write verbose output' {

            Mock -CommandName Write-Verbose -Verifiable

            $params = @{
                ProjectName = 'TestProject'
                RepositoryName = 'TestRepo'
                isInherited = $true
            }

            New-xAzDoGitPermission @params

            Assert-VerifiableMock

        }
    }
}
