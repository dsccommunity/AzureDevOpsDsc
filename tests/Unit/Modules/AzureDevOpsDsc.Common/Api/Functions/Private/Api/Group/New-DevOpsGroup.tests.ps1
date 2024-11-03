$currentFile = $MyInvocation.MyCommand.Path

Describe "New-DevOpsGroup" -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-DevOpsGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{
                displayName = $GroupName
                description = $GroupDescription
                id = "mock-id"
            }
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "6.0" }
    }

    Context "When required parameters are provided" {
        It 'Creates a new group successfully' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"

            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
            $result.displayName | Should -Be $GroupName
        }
    }

    Context "When optional parameters are provided" {
        It 'Creates a new group successfully with description' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"
            $GroupDescription = "A sample group"

            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
            $result.description | Should -Be $GroupDescription
        }

        It 'Creates a new group successfully with project scope descriptor' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"
            $ProjectScopeDescriptor = "vstfs:///Classification/TeamProject/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -ProjectScopeDescriptor $ProjectScopeDescriptor

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
            $result.displayName | Should -Be $GroupName
        }
    }

    Context "When an exception is thrown" {
        BeforeAll {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API call failed" }
            Mock -CommandName Write-Error -Verifiable
        }

        It 'Handles the error and writes an error message' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"

            { New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName } | Should -Not -Throw
        }
    }
}
