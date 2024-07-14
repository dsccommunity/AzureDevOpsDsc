powershell
# Import the Pester module
Import-Module Pester

# Pester tests for New-xAzDoGitRepository function
Describe "New-xAzDoGitRepository Tests" {
    # Mock external cmdlets/functions 
    Mock Get-CacheItem { return @{ Name = "TestProject" } }
    Mock New-GitRepository { return @{ Name = $RepositoryName } }
    Mock Add-CacheItem { }
    Mock Export-CacheObject { }
    
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
            
            Assert-MockCalled New-GitRepository -Exactly -Times 1
        }
        
        It "should call Add-CacheItem" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
            }
            New-xAzDoGitRepository @params
            
            Assert-MockCalled Add-CacheItem -Exactly -Times 1
        }
        
        It "should call Export-CacheObject" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
            }
            New-xAzDoGitRepository @params
            
            Assert-MockCalled Export-CacheObject -Exactly -Times 1
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
            
            Assert-MockCalled New-GitRepository -ParameterFilter { $RepositoryName -eq 'TestRepo' -and $SourceRepository -eq 'SourceRepo' }
        }

        It "should handle Force switch parameter" {
            $params = @{
                ProjectName     = 'TestProject'
                RepositoryName  = 'TestRepo'
                Force           = $true
            }
            New-xAzDoGitRepository @params
            
            # Since Force is not used in function logic directly, verifying other aspects
            Assert-MockCalled New-GitRepository -Exactly -Times 1
        }
    }
}

