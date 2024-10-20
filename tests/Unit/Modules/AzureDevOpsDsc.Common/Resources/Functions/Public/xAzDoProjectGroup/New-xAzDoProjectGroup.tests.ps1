# Save this script as New-xAzDoProjectGroup.Tests.ps1

$currentFile = $MyInvocation.MyCommand.Path

Describe 'New-xAzDoProjectGroup' {

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-xAzDoProjectGroup.tests.ps1'
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

        # Mocking external dependencies
        Mock -CommandName Write-Verbose
        Mock -CommandName Write-Warning
        Mock -CommandName New-DevOpsGroup -MockWith {
            return [PSCustomObject]@{ principalName = "TestPrincipal" }
        }
        Mock -CommandName Get-CacheItem
        Mock -CommandName Add-CacheItem
        Mock -CommandName Set-CacheObject
        Mock -CommandName Refresh-CacheIdentity

    }

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'TestOrg'
        $Global:AzDoGroup = @()
    }

    Context 'when ProjectScopeDescriptor is found' {
        BeforeEach {
            Mock -CommandName Get-CacheItem -MockWith {
                return [PSCustomObject]@{ ProjectDescriptor = 'ProjectDescriptor123' }
            }
        }

        It 'should create a new DevOps group' {
            $params = @{
                GroupName = 'TestGroup'
                ProjectName = 'TestProject'
            }

            $result = New-xAzDoProjectGroup @params

            Assert-MockCalled Get-CacheItem -Exactly 1
            Assert-MockCalled New-DevOpsGroup -Exactly 1
            Assert-MockCalled Add-CacheItem -Exactly 1
            Assert-MockCalled Set-CacheObject -Exactly 1
            Assert-MockCalled Refresh-CacheIdentity -Exactly 1
        }

        It 'should update caches correctly' {
            $params = @{
                GroupName = 'TestGroup'
                ProjectName = 'TestProject'
            }

            $result = New-xAzDoProjectGroup @params

            Assert-MockCalled Add-CacheItem -Exactly 1
            Assert-MockCalled Set-CacheObject -Exactly 1
            Assert-MockCalled Refresh-CacheIdentity -Exactly 1
        }
    }

    Context 'when ProjectScopeDescriptor is not found' {
        BeforeEach {
            Mock -CommandName Get-CacheItem -MockWith {
                return $null
            }
        }

        It 'should write a warning and abort the group creation' {
            $params = @{
                GroupName = 'TestGroup'
                ProjectName = 'TestProject'
            }

            $result = New-xAzDoProjectGroup @params

            Assert-MockCalled Get-CacheItem -Exactly 1
            Assert-MockCalled Write-Warning -Exactly 1
            Assert-MockCalled New-DevOpsGroup -Exactly 0
            Assert-MockCalled Add-CacheItem -Exactly 0
            Assert-MockCalled Set-CacheObject -Exactly 0
            Assert-MockCalled Refresh-CacheIdentity -Exactly 0
        }
    }
}
