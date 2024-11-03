$currentFile = $MyInvocation.MyCommand.Path

Describe 'Test-AzToken' -Tags "Unit", "Authentication" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzToken.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Test-AzDevOpsApiHttpRequestHeader -MockWith {
            return $true
        }

        $GLOBAL:DSCAZDO_OrganizationName = "TestOrg"

    }

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    Context 'When token is valid' {
        It 'Should return true' {
            # Mocking the Managed Identity token object
            $mockToken = [PSCustomObject]@{}
            $mockToken | Add-Member -MemberType ScriptMethod -Name Get -Value {
                return "valid_token"
            }

            # Mocking the Invoke-AzDevOpsApiRestMethod cmdlet
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return "valid_token"
            }

            $result = Test-AzToken -Token $mockToken
            $result | Should -Be $true
        }
    }

    Context 'When token is invalid' {
        It 'Should return false' {
            # Mocking the Managed Identity token object
            $mockToken = [PSCustomObject]@{}
            $mockToken | Add-Member -MemberType ScriptMethod -Name Get -Value {
                return "invalid_token"
            }

            # Mocking the Invoke-AzDevOpsApiRestMethod cmdlet to throw an exception
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                throw "Unauthorized"
            }

            $result = Test-AzToken -Token $mockToken
            $result | Should -Be $false
        }
    }
}
