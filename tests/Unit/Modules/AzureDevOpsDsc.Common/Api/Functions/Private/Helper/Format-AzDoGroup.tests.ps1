$currentFile = $MyInvocation.MyCommand.Path

Describe 'Format-AzDoGroup' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Format-AzDoGroup.tests.ps1"
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    Context 'Formatting UPN' {
        It 'Should format correctly with valid inputs' {
            Mock -CommandName Format-AzDoGroup -MockWith {
                param (
                    [string]$Prefix,
                    [string]$GroupName
                )

                return '[{0}]\{1}' -f $Prefix.Trim('[]'), $GroupName
            }

            $result = Format-AzDoGroup -Prefix "Contoso" -GroupName "Developers"
            $result | Should -Be "[Contoso]\Developers"
        }

        It 'Should remove starting/ending square brackets from Prefix' {
            Mock -CommandName Format-AzDoGroup -MockWith {
                param (
                    [string]$Prefix,
                    [string]$GroupName
                )

                return '[{0}]\{1}' -f $Prefix.Trim('[]'), $GroupName
            }

            $result = Format-AzDoGroup -Prefix "[Contoso]" -GroupName "Developers"
            $result | Should -Be "[Contoso]\Developers"
        }

        It 'Should remove starting/ending square brackets from Prefix' {
            Mock -CommandName Format-AzDoGroup -MockWith {
                param (
                    [string]$Prefix,
                    [string]$GroupName
                )

                return '[{0}]\{1}' -f $Prefix.Trim('[]'), $GroupName
            }

            $result = Format-AzDoGroup -Prefix "[Contoso]" -GroupName "Developers"
            $result | Should -Be "[Contoso]\Developers"
        }
    }
}
