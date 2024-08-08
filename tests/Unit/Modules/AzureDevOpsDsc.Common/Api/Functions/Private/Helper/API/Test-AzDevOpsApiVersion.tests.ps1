Describe 'Test-AzDevOpsApiVersion' {
    BeforeAll {
        function Test-AzDevOpsApiVersion {
            param (
                [Parameter(Mandatory = $true)]
                [System.String]
                $ApiVersion,

                [Parameter(Mandatory = $true)]
                [ValidateSet($true)]
                [System.Management.Automation.SwitchParameter]
                $IsValid
            )

            $supportedApiVersions = @(
                '6.0'
            )

            return !(!$supportedApiVersions.Contains($ApiVersion))
        }
    }

    It 'Should return $true for supported API version' {
        $result = Test-AzDevOpsApiVersion -ApiVersion '6.0' -IsValid
        $result | Should -Be $true
    }

    It 'Should return $false for unsupported API version' {
        $result = Test-AzDevOpsApiVersion -ApiVersion '5.0' -IsValid
        $result | Should -Be $false
    }

    It 'Should throw an error if -IsValid switch is missing' {
        { Test-AzDevOpsApiVersion -ApiVersion '6.0' } | Should -Throw
    }

    It 'Should throw an error if ApiVersion is not provided' {
        { Test-AzDevOpsApiVersion -IsValid } | Should -Throw
    }
}

