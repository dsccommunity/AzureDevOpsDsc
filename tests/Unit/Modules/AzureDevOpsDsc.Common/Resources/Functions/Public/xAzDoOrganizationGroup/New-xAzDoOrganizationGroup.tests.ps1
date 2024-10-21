$currentFile = $MyInvocation.MyCommand.Path

Describe 'New-AzDoOrganizationGroup' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-AzDoOrganizationGroup.tests.ps1'
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

        # Mock the external functions used within New-AzDoOrganizationGroup
        Mock -CommandName New-DevOpsGroup -MockWith {
            return @{
                principalName = "testPrincipalName"
            }
        }

        Mock -CommandName Refresh-CacheIdentity
        Mock -CommandName Add-CacheItem
        Mock -CommandName Set-CacheObject

    }

    Context 'When GroupName is provided' {
        It 'Should create a new DevOps group with correct parameters' {
            $params = @{
                GroupName = 'TestGroup'
                GroupDescription = 'Test Description'
            }

            $result = New-AzDoOrganizationGroup @params

            Assert-MockCalled -CommandName New-DevOpsGroup -Exactly -Times 1
            Assert-MockCalled -CommandName Refresh-CacheIdentity -Exactly -Times 1
            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 1
            Assert-MockCalled -CommandName Set-CacheObject -Exactly -Times 1
        }
    }

    Context 'Verbose logs' {
        It 'Should log verbose messages' {

            Mock -CommandName Write-Verbose

            $params = @{
                GroupName = 'TestGroup'
                GroupDescription = 'Test Description'
                Verbose = $true
            }

            $verboseOutput = New-AzDoOrganizationGroup @params

            Assert-MockCalled -CommandName Write-Verbose -ParameterFilter { $Message -like "*Creating a new DevOps group with GroupName: 'TestGroup', GroupDescription: 'Test Description'*" }
            Assert-MockCalled -CommandName Write-Verbose -ParameterFilter { $Message -like "*Updated global AzDoGroup cache object.*" }
        }
    }
}
