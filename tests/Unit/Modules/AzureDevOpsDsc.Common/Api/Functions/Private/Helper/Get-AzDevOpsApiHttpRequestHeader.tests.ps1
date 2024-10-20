$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-AzDevOpsApiHttpRequestHeader' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Get-AzDevOpsApiHttpRequestHeader.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Test-AzDevOpsPat -MockWith {
            param (
                [string]$Pat
            )
            return $true
        }

    }

    Context 'when called with valid PAT' {
        It 'should return a hashtable with Authorization header' {
            $Pat = 'ValidPAT'
            $ExpectedHeader = @{
                Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
            }

            $Result = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

            $Result | Should -BeOfType 'Hashtable'
            $Result['Authorization'] | Should -BeExactly $ExpectedHeader['Authorization']
        }
    }

    Context 'when called with invalid PAT' {
        It 'should throw a validation exception' {

            Mock -CommandName Test-AzDevOpsPat -MockWith {
                return $false
            }

            { Get-AzDevOpsApiHttpRequestHeader -Pat 'InvalidPAT' } | Should -Throw

        }
    }
}
