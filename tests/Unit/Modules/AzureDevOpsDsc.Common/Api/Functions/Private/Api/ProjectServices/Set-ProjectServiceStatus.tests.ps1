
Describe 'Set-ProjectServiceStatus' {
    Mock Get-AzDevOpsApiVersion {
        return '6.0'
    }

    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            state = 'Enabled'
        }
    }

    It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
        Param (
            [string]$Organization = 'TestOrg',
            [string]$ProjectId = 'TestProjId',
            [string]$ServiceName = 'Git',
            [Object]$Body = @{
                state = 'Enabled'
            },
            [string]$ApiVersion
        )

        $expectedUri = 'https://dev.azure.com/TestOrg/_apis/FeatureManagement/FeatureStates/host/project/TestProjId/Git?api-version=6.0'

        Set-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -Body $Body -ApiVersion $ApiVersion

        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
            $Uri -eq $expectedUri -and $Method -eq 'PATCH' -and $Body -eq ($Body | ConvertTo-Json)
        } -Exactly -Times 1
    }

    It 'should return the state of the service if the API call is successful' {
        $Organization = 'TestOrg'
        $ProjectId = 'TestProjId'
        $ServiceName = 'Git'
        $Body = @{
            state = 'Enabled'
        }

        $result = Set-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -Body $Body

        $result | Should -Be 'Enabled'
    }

    It 'should return error message when API call fails' {
        Mock Invoke-AzDevOpsApiRestMethod {
            throw "API call failed"
        }

        $Organization = 'TestOrg'
        $ProjectId = 'TestProjId'
        $ServiceName = 'Git'
        $Body = @{
            state = 'Enabled'
        }

        { Set-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -Body $Body } | Should -Throw -ErrorMessage "Failed to set Security Descriptor: API call failed"
    }
}

