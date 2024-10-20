$currentFile = $MyInvocation.MyCommand.Path
# Not used
Describe 'Get-AzDevOpsApiUriAreaName' -skip {
    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDevOpsApiUriAreaName.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    Context 'When ResourceName is provided and valid' {
        It 'Should return corresponding URI-specific area name' {
            $result = Get-AzDevOpsApiUriAreaName -ResourceName 'Project'
            $result | Should -Be 'core'
        }

        It 'Should return another URI-specific area name' {
            $result = Get-AzDevOpsApiUriAreaName -ResourceName 'Profile'
            $result | Should -Be 'profile'
        }
    }

    Context 'When no ResourceName is provided' {
        It 'Should return all unique URI-specific area names' {
            $result = Get-AzDevOpsApiUriAreaName
            $result | Should -Contain 'core'
            $result | Should -Contain 'profile'
            $result.Count | Should -Be 2
        }
    }

    Context 'When invalid ResourceName is provided' {
        It 'Should throw validation exception' {
            { Get-AzDevOpsApiUriAreaName -ResourceName 'Invalid' } | Should -Throw
        }
    }
}

