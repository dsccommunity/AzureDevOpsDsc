$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-AzDevOpsProject' {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzDevOpsProject.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

    }


    Mock -CommandName Get-CacheItem -MockWith {
        return @{
            Key = $using:ProjectName
            Value = @{
                ProjectId = $using:ProjectId
                ProjectName = $using:ProjectName
            }
        }
    }

    It 'Should return the project from cache when ProjectName is provided' {
        $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName
        $result | Should -Not -BeNullOrEmpty
        $result.ProjectId | Should -Be $ProjectId
        $result.ProjectName | Should -Be $ProjectName
    }

    It 'Should validate the ApiUri' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['ApiUri'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $ApiUri
        $result | Should -Be $true
    }

    It 'Should validate the Pat' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['Pat'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $Pat
        $result | Should -Be $true
    }

    It 'Should validate the ProjectId' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['ProjectId'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $ProjectId
        $result | Should -Be $true
    }

    It 'Should validate the ProjectName' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['ProjectName'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $ProjectName
        $result | Should -Be $true
    }

    It 'Should return the project from cache when both ProjectId and ProjectName are provided' {
        $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName
        $result | Should -Not -BeNullOrEmpty
        $result.ProjectId | Should -Be $ProjectId
        $result.ProjectName | Should -Be $ProjectName
    }
}
