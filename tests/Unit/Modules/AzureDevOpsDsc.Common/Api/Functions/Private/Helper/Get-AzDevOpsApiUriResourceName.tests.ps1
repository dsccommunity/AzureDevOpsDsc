powershell
Describe 'Get-AzDevOpsApiUriResourceName' {
    Context 'No Parameter' {
        It 'Should return all Azure DevOps API URI resource names' {
            $result = Get-AzDevOpsApiUriResourceName
            $expected = @('operations', 'projects')
            $result | Should -BeOfType [System.String[]]
            $result | Should -Be $expected
        }
    }

    Context 'With ResourceName Parameter' {
        It 'Should return the correct URI-specific resource name for Operation' {
            $result = Get-AzDevOpsApiUriResourceName -ResourceName 'Operation'
            $expected = 'operations'
            $result | Should -BeOfType [System.String]
            $result | Should -Be $expected
        }

        It 'Should return the correct URI-specific resource name for Project' {
            $result = Get-AzDevOpsApiUriResourceName -ResourceName 'Project'
            $expected = 'projects'
            $result | Should -BeOfType [System.String]
            $result | Should -Be $expected
        }

        It 'Should return $null if an invalid ResourceName is provided' {
            $result = Get-AzDevOpsApiUriResourceName -ResourceName 'InvalidResource'
            $result | Should -Be $null
        }

        It 'Should throw an error if ResourceName is whitespace' {
            { Get-AzDevOpsApiUriResourceName -ResourceName ' ' } | Should -Throw
        }
    }
}

Function Test-AzDevOpsApiResourceName {
    param (
        [string] $ResourceName,
        [bool] $IsValid
    )
    if ($IsValid) {
        return $true
    } else {
        return $false
    }
}

