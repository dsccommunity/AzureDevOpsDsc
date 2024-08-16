
Describe 'Remove-DevOpsGroup' {
    Param (
        [string]$ApiUri = "https://dev.azure.com/myorganization",
        [string]$ApiVersion = "6.0",
        [string]$GroupDescriptor = "MyGroup"
    )

    Mock Get-AzDevOpsApiVersion -MockWith { "6.0" }
    Mock Invoke-AzDevOpsApiRestMethod {
        [PSCustomObject]@{ success = $true }
    }

    Context 'When all mandatory parameters are provided' {
        It 'should make a DELETE request to Azure DevOps API' {
            $result = Remove-DevOpsGroup -ApiUri $ApiUri -GroupDescriptor $GroupDescriptor

            $params = @{
                Uri = "$ApiUri/_apis/graph/groups/$GroupDescriptor?api-version=$ApiVersion"
                Method = 'Delete'
                ContentType = 'application/json'
            }

            Should -InvokeCommand 'Invoke-AzDevOpsApiRestMethod' -Exactly -WithArguments $params
            $result.success | Should -Be $true
        }
    }

    Context 'When ApiVersion parameter is not provided' {
        It 'should use the default ApiVersion' {
            Mock Get-AzDevOpsApiVersion -MockWith { "6.0" }

            $result = Remove-DevOpsGroup -ApiUri $ApiUri -GroupDescriptor $GroupDescriptor

            Should -InvokeCommand 'Get-AzDevOpsApiVersion' -Times 1
            $result.success | Should -Be $true
        }
    }

    Context 'When an error occurs during the API call' {
        Mock Invoke-AzDevOpsApiRestMethod -MockWith {
            throw "API call failed"
        }

        It 'should catch and log the error' {
            { Remove-DevOpsGroup -ApiUri $ApiUri -GroupDescriptor $GroupDescriptor } | Should -Throw

            $error[0].Exception.Message | Should -Be "Failed to remove group: API call failed"
        }
    }
}

