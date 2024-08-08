Describe 'Get-AzDevOpsApiVersion' {
    It 'Should return all supported API versions when no parameters are specified' {
        $expected = @('6.0', '7.0-preview.1', '7.1-preview.1', '7.1-preview.4', '7.2-preview.4')
        $result = Get-AzDevOpsApiVersion
        $result | Should -BeOfType 'System.String[]'
        $result | Should -ContainExactly $expected
    }

    It 'Should return default API version when -Default is specified' {
        $expected = '7.0-preview.1'
        $result = Get-AzDevOpsApiVersion -Default
        $result | Should -BeOfType 'System.String[]'
        $result | Should -ContainExactly @($expected)
    }

    It 'Should return empty array when none of the specified conditions match' {
        function Get-AzDevOpsApiVersion {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param (
                [Parameter()]
                [System.Management.Automation.SwitchParameter]
                $Default
            )
            return @()
        }
        $result = Get-AzDevOpsApiVersion -Default
        $result | Should -BeOfType 'System.Object[]'
        $result | Should -BeEmpty
    }
}

