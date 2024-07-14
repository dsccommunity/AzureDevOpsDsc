powershell
Describe 'New-xAzDoProjectGroup' {

    Mock -ModuleName Microsoft.PowerShell.Utility -CommandName Write-Verbose
    Mock -ModuleName Microsoft.PowerShell.Utility -CommandName Write-Warning
    Mock -CommandName New-DevOpsGroup
    Mock -CommandName Get-CacheItem
    Mock -CommandName Add-CacheItem
    Mock -CommandName Set-CacheObject

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'TestOrg'
        $Global:AZDOLiveGroups = @()
        $Global:AzDoGroup = @()
    }

    Context 'when ProjectScopeDescriptor is found' {

        BeforeEach {
            Mock Get-CacheItem { 
                return @{
                    ProjectDescriptor = 'ProjectDescriptor123'
                }
            }
        }

        It 'should create a new DevOps group' {
            $params = @{
                GroupName = 'TestGroup'
                ProjectName = 'TestProject'
            }

            $result = New-xAzDoProjectGroup @params

            Assert-MockCalled Get-CacheItem -Exactly 1 -Scope It
            Assert-MockCalled New-DevOpsGroup -Exactly 1 -Scope It
            Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
            Assert-MockCalled Set-CacheObject -Exactly 2 -Scope It
        }

        It 'should add the new group to caches' {
            $params = @{
                GroupName = 'TestGroup'
                ProjectName = 'TestProject'
            }

            $result = New-xAzDoProjectGroup @params

            Assert-MockCalled Add-CacheItem -Exactly 2 -Scope It
            Assert-MockCalled Set-CacheObject -Exactly 2 -Scope It
        }
    }

    Context 'when ProjectScopeDescriptor is not found' {

        BeforeEach {
            Mock Get-CacheItem {
                return $null
            }
        }

        It 'should write a warning and abort the group creation' {
            $params = @{
                GroupName = 'TestGroup'
                ProjectName = 'TestProject'
            }

            $result = New-xAzDoProjectGroup @params

            Assert-MockCalled Get-CacheItem -Exactly 1 -Scope It
            Assert-MockCalled Write-Warning -Exactly 1 -Scope It
            Assert-MockCalled New-DevOpsGroup -Exactly 0 -Scope It
            Assert-MockCalled Add-CacheItem -Exactly 0 -Scope It
            Assert-MockCalled Set-CacheObject -Exactly 0 -Scope It
        }
    }
}

