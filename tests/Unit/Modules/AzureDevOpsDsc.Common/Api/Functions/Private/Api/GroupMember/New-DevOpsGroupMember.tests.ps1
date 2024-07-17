powershell
Describe 'New-DevOpsGroupMember' {
    # Mock function to simulate Get-AzDevOpsApiVersion
    function Get-AzDevOpsApiVersion {
        param()
        return '6.0-preview.1'
    }

    # Mock function to simulate Invoke-AzDevOpsApiRestMethod
    function Invoke-AzDevOpsApiRestMethod {
        param (
            [string]$Uri,
            [string]$Method
        )
        return @{ result = 'success' }
    }

    Context 'With valid parameters' {
        It 'Should call Invoke-AzDevOpsApiRestMethod and return result from REST method' {
            # Arrange
            $group = [PSCustomObject]@{ descriptor = 'group-descriptor' }
            $member = [PSCustomObject]@{ descriptor = 'member-descriptor' }
            $apiUri = 'https://dev.azure.com/organization'

            # Act
            $result = New-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri

            # Assert
            $result.result | Should -Be 'success'
            (Get-Command Invoke-AzDevOpsApiRestMethod).Parameters.Keys | Should -Contain 'Uri'
            (Get-Command Invoke-AzDevOpsApiRestMethod).Parameters.Keys | Should -Contain 'Method'
        }
    }

    Context 'When REST method fails' {
        It 'Should catch the exception and write an error' {
            # Arrange
            $group = [PSCustomObject]@{ descriptor = 'group-descriptor' }
            $member = [PSCustomObject]@{ descriptor = 'member-descriptor' }
            $apiUri = 'https://dev.azure.com/organization'
            
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                throw [System.Exception]::new('REST call failed.')
            }

            # Act & Assert
            { New-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $apiUri } | Should -Throw -ExceptionMessage 'REST call failed.'
        }
    }

    Context 'With default API version' {
        It 'Should use the default API version if not provided' {
            # Arrange
            $group = [PSCustomObject]@{ descriptor = 'group-descriptor' }
            $member = [PSCustomObject]@{ descriptor = 'member-descriptor' }

            $global:ApiUri = 'https://dev.azure.com/organization'
            $global:ApiVersion = '6.0-preview.1'

            Mock -CommandName Get-AzDevOpsApiVersion -MockWith {
                $global:ApiVersion
            }

            # Act
            $result = New-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri $global:ApiUri

            # Assert
            $result.result | Should -Be 'success'
            $params = Get-MockCalledInvoke -ModuleName Pester -Mock Invoke-AzDevOpsApiRestMethod
            $params.Parameters.ApiVersion | Should -Be $global:ApiVersion
        }
    }
}

