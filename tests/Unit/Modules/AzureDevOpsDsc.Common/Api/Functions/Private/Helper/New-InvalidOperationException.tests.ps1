$currentFile = $MyInvocation.MyCommand.Path

Describe 'New-InvalidOperationException' -Skip {

    BeforeAll {

        Mock -CommandName New-InvalidOperationException -MockWith {
            param (
                [string]$Message,
                [switch]$Throw
            )

            if (-not $Message) {
                throw [System.Management.Automation.ParameterBindingValidationException]::new("Message parameter cannot be null or empty")
            }

            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new($Message),
                "InvalidOperation",
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $null
            )

            if ($Throw) {
                throw $errorRecord
            }

            return $errorRecord
        }

    }

    It 'Should return an ErrorRecord when given a valid message' {
        $message = 'An error occurred'
        $result = New-InvalidOperationException -Message $message
        $result | Should -BeOfType [System.Management.Automation.ErrorRecord]
        $result.Exception.Message | Should -BeExactly $message
        $result.CategoryInfo.Category | Should -Be [System.Management.Automation.ErrorCategory]::ConnectionError
    }

    It 'Should throw an ErrorRecord when -Throw is specified' {
        $message = 'An error occurred'
        { New-InvalidOperationException -Message $message -Throw } | Should -Throw -ExceptionType [System.Management.Automation.ErrorRecord]
    }

    It 'Should fail if Message parameter is null' {
        { New-InvalidOperationException -Message $null } | Should -Throw -ExceptionType [System.Management.Automation.ParameterBindingValidationException]
    }

    It 'Should fail if Message parameter is empty' {
        { New-InvalidOperationException -Message '' } | Should -Throw -ExceptionType [System.Management.Automation.ParameterBindingValidationException]
    }
}
