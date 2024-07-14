
# Unit Tests for New-InvalidOperationException function using Pester v5

Describe 'New-InvalidOperationException' {

    BeforeAll {
        Import-Module -Name 'Path\To\The\Module.psm1' -Force
    }

    Context 'When passed a message and Throw is not specified' {
        It 'Should return an ErrorRecord object' {
            $Message = "An error has occurred"
            $result = New-InvalidOperationException -Message $Message

            $result | Should -BeOfType 'System.Management.Automation.ErrorRecord'
            $result.Exception.Message | Should -Be $Message
            $result.FullyQualifiedErrorId | Should -Be 'System.InvalidOperationException'
            $result.CategoryInfo.Category | Should -Be [System.Management.Automation.ErrorCategory]::ConnectionError
        }
    }

    Context 'When passed a message and Throw is specified' {
        It 'Should throw the ErrorRecord' {
            $Message = "An error has occurred"
            { New-InvalidOperationException -Message $Message -Throw } | Should -Throw 'System.InvalidOperationException'
        }
    }

    Context 'When the Message parameter is null or empty' {
        It 'Should throw a validation exception' {
            { New-InvalidOperationException -Message $null } | Should -Throw 'System.Management.Automation.ParameterBindingValidationException'
            { New-InvalidOperationException -Message '' } | Should -Throw 'System.Management.Automation.ParameterBindingValidationException'
        }
    }
}

