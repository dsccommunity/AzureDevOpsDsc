Describe 'Set-ProjectServiceStatus' {
    Mock Get-AzDevOpsApiVersion { '6.0-preview.1' }
    Mock Invoke-AzDevOpsApiRestMethod {
        [PSCustomObject]@{ state = 'enabled' }
    }

    Context 'When all required parameters are provided' {
        It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $org = 'TestOrg'
            $projId = 'TestProj'
            $srvName = 'TestService'
            $body = [PSCustomObject]@{ status = 'enable' }

            $result = Set-ProjectServiceStatus -Organization $org -ProjectId $projId -ServiceName $srvName -Body $body

            $expectedUri = 'https://dev.azure.com/TestOrg/_apis/FeatureManagement/FeatureStates/host/project/TestProj/TestService?api-version=6.0-preview.1'

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1 -Scope It
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $_.Uri -eq $expectedUri -and
                $_.Method -eq 'PATCH' -and
                $_.Body -eq ($body | ConvertTo-Json)
            }

            $result | Should -Be 'enabled'
        }
    }

    Context 'When ApiVersion parameter is provided' {
        It 'should use the provided ApiVersion' {
            $org = 'TestOrg'
            $projId = 'TestProj'
            $srvName = 'TestService'
            $body = [PSCustomObject]@{ status = 'enable' }
            $apiVersion = '5.1'

            $result = Set-ProjectServiceStatus -Organization $org -ProjectId $projId -ServiceName $srvName -Body $body -ApiVersion $apiVersion

            $expectedUri = 'https://dev.azure.com/TestOrg/_apis/FeatureManagement/FeatureStates/host/project/TestProj/TestService?api-version=5.1'

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $_.Uri -eq $expectedUri -and
                $_.Method -eq 'PATCH' -and
                $_.Body -eq ($body | ConvertTo-Json)
            }
        }
    }

    Context 'When an error occurs' {
        Mock Invoke-AzDevOpsApiRestMethod { throw 'Error' }

        It 'should catch the error and write an error message' {
            $org = 'TestOrg'
            $projId = 'TestProj'
            $srvName = 'TestService'
            $body = [PSCustomObject]@{ status = 'enable' }

            { Set-ProjectServiceStatus -Organization $org -ProjectId $projId -ServiceName $srvName -Body $body } | Should -Throw

            Get-Content -Path $Error[0] | Should -Match 'Failed to set Security Descriptor:'
        }
    }
}

