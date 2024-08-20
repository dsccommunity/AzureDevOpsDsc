$currentFile = $MyInvocation.MyCommand.Path

Describe 'Remove-DevOpsGroup' {
    Param (
        [string]$ApiUri = "https://dev.azure.com/myorganization",
        [string]$ApiVersion = "6.0",
        [string]$GroupDescriptor = "MyGroup"
    )

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { "6.0" }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            [PSCustomObject]@{ success = $true }
        }

        $Uri = "https://dev.azure.com/myorganization"
        $GroupDescriptor = "MyGroup"
        $ApiVersion = "6.0"
    }

    Context 'When all mandatory parameters are provided' {
        It 'should make a DELETE request to Azure DevOps API' {

            $params = @{
                Uri = '{0}/_apis/graph/groups/{1}?api-version={2}' -f $Uri, $GroupDescriptor, $ApiVersion
                Method = 'Delete'
            }

            $result = Remove-DevOpsGroup -ApiUri $Uri -GroupDescriptor $GroupDescriptor

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
                $ApiUri -eq $params.Uri -and
                $Method -eq $params.Method
            }
            $result.success | Should -Be $true
        }
    }

    Context 'When ApiVersion parameter is not provided' {
        It 'should use the default ApiVersion' {
            Mock -CommandName Get-AzDevOpsApiVersion -MockWith { "6.0" }

            $result = Remove-DevOpsGroup -ApiUri $Uri -GroupDescriptor $GroupDescriptor

            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly -Times 1
            $result.success | Should -Be $true
        }
    }

    Context 'When an error occurs during the API call' {
        BeforeAll {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                throw "API call failed"
            }

            Mock -CommandName Write-Error -Verifiable
        }

        It 'should catch and log the error' {
            { Remove-DevOpsGroup -ApiUri $Uri -GroupDescriptor $GroupDescriptor } | Should -Not -Throw
        }
    }
}
