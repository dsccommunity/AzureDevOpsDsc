$currentFile = $MyInvocation.MyCommand.Path

Describe "Test-AzDevOpsProject" -Skip {

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDoProject.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')

        $fakeUri = "https://dev.azure.com/fakeOrganization/_apis/"
        $fakePat = "fakePat"
        $fakeProjectId = "fakeProjectId"
        $fakeProjectName = "fakeProjectName"

        Mock -CommandName Test-AzDevOpsApiUri -MockWith {
            return $true
        }

        Mock -CommandName Test-AzDevOpsPat -MockWith {
            return $true
        }

        Mock -CommandName Test-AzDevOpsProjectId -MockWith {
            return $true
        }

        Mock -CommandName Test-AzDevOpsProjectName -MockWith {
            return $true
        }

        Mock -CommandName Get-AzDevOpsProject -MockWith {
            return @{ id = $fakeProjectId }
        }

    }

    It "Should return true when project exists by ProjectId" {
        $result = Test-AzDevOpsProject -ApiUri $fakeUri -Pat $fakePat -ProjectId $fakeProjectId
        $result | Should -Be $true
    }

    It "Should return true when project exists by ProjectName" {
        $result = Test-AzDevOpsProject -ApiUri $fakeUri -Pat $fakePat -ProjectName $fakeProjectName
        $result | Should -Be $true
    }

    It "Should return true when project exists by ProjectId and ProjectName" {
        $result = Test-AzDevOpsProject -ApiUri $fakeUri -Pat $fakePat -ProjectId $fakeProjectId -ProjectName $fakeProjectName
        $result | Should -Be $true
    }

    It "Should return false when project does not exist" {
        Mock -CommandName Get-AzDevOpsProject -MockWith {
            param ($ApiUri, $Pat, $ProjectId, $ProjectName)
            return $null
        }

        $result = Test-AzDevOpsProject -ApiUri $fakeUri -Pat $fakePat -ProjectId $fakeProjectId
        $result | Should -Be $false
    }
}
