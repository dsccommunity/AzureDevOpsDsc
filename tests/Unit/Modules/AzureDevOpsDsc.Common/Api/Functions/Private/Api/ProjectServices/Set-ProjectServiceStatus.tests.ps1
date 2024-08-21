$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-ProjectServiceStatus' {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith {
            return '6.0'
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{
                state = 'Enabled'
            }
        }

    }

    It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {

        $Organization = 'TestOrg'
        $ProjectId = 'TestProjId'
        $ServiceName = 'Git'
        $Body = @{
                state = 'Enabled'
            }
        $ApiVersion = '6.0'


        $expectedUri = 'https://dev.azure.com/TestOrg/_apis/FeatureManagement/FeatureStates/host/project/TestProjId/Git?api-version=6.0'

        Set-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -Body $Body -ApiVersion $ApiVersion

        Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
            $Uri -eq $expectedUri -and
            $Method -eq 'PATCH'
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
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            throw "API call failed"
        }

        Mock -CommandName Write-Error -Verifiable

        $Organization = 'TestOrg'
        $ProjectId = 'TestProjId'
        $ServiceName = 'Git'
        $Body = @{
            state = 'Enabled'
        }

        { Set-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -Body $Body } | Should -Not -Throw
    }
}
