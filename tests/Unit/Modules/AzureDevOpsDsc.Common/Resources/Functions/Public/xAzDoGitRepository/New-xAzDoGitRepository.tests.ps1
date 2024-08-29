$currentFile = $MyInvocation.MyCommand.Path

# Pester tests for New-xAzDoGitRepository function
Describe "New-xAzDoGitRepository Tests" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-xAzDoGitRepository.tests.ps1'
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

        # Mock external cmdlets/functions
        Mock -CommandName Get-CacheItem -MockWith { return @{ Name = "TestProject" } }
        Mock -CommandName New-GitRepository -MockWith { return @{ Name = $RepositoryName } }
        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    Context "When mandatory parameters are provided" {

        BeforeEach {
            $Global:DSCAZDO_OrganizationName = "TestOrg"
        }

        It "should call New-GitRepository" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
            }
            New-xAzDoGitRepository @params

            Assert-MockCalled -CommandName New-GitRepository -Exactly -Times 1
        }

        It "should call Add-CacheItem" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
            }
            New-xAzDoGitRepository @params

            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 1
        }

        It "should call Export-CacheObject" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
            }
            New-xAzDoGitRepository @params

            Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 1
        }

    }

    Context "When optional parameters are provided" {

        It "should pass SourceRepository to New-GitRepository" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
                SourceRepository= 'SourceRepo'
            }
            New-xAzDoGitRepository @params

            Assert-MockCalled -CommandName New-GitRepository -ParameterFilter { $RepositoryName -eq 'TestRepo' -and $SourceRepository -eq 'SourceRepo' }
        }

        It "should handle Force switch parameter" -skip {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
                Force           = $true
            }
            New-xAzDoGitRepository @params

            # Since Force is not used in function logic directly, verifying other aspects
            Assert-MockCalled -CommandName New-GitRepository -Exactly -Times 1
        }
    }

    Context 'When the cache returns $null' {

        BeforeEach {
            Mock -CommandName Get-CacheItem -MockWith { return $null }
        }

        It "should process the repository creation" {

            Mock -CommandName Write-Error -Verifiable
            Mock -CommandName Get-CacheItem -MockWith { return $null }

            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
            }
            New-xAzDoGitRepository @params

            Assert-VerifiableMock
            Assert-MockCalled -CommandName New-GitRepository -Exactly -Times 0
        }

    }

}
