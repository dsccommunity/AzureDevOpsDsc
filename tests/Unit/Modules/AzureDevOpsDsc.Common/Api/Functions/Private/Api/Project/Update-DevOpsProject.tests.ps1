powershell
Describe 'Update-DevOpsProject' {
    $functionName = 'Update-DevOpsProject'

    BeforeAll {
        function Test-AzDevOpsPat {
            param (
                [string]$Pat,
                [bool]$IsValid
            )
            return $IsValid
        }

        function Invoke-AvDevOpsApiRestMethod {
            param ($Uri, $Body, $Method, $Headers)
            return @{
                status = 'Success'
                updatedName = $Body.name
                updatedDescription = $Body.description
                updatedVisibility = $Body.visibility
            }
        }
    }

    Context 'When all parameters are provided' {
        $params = @{
            Organization = "contoso"
            ProjectId = "MyProject"
            NewName = "NewProjectName"
            Description = "Updated project description"
            Visibility = "public"
            PersonalAccessToken = "fakePAT"
        }

        It 'Should update the project successfully' {
            $result = & $functionName @params
            $result.status | Should -Be 'Success'
            $result.updatedName | Should -Be $params.NewName
            $result.updatedDescription | Should -Be $params.Description
            $result.updatedVisibility | Should -Be $params.Visibility
        }
    }

    Context 'When required parameters are missing' {
        It 'Should throw an error when Organization is missing' {
            {
                & $functionName -ProjectId "MyProject"
            } | Should -Throw
        }

        It 'Should throw an error when ProjectId is missing' {
            {
                & $functionName -Organization "contoso"
            } | Should -Throw
        }
    }

    Context 'When optional parameters are not provided' {
        $params = @{
            Organization = "contoso"
            ProjectId = "MyProject"
        }

        It 'Should use default values for optional parameters' {
            $result = & $functionName @params
            $result.status | Should -Be 'Success'
            $result.updatedVisibility | Should -Be 'private'
        }
    }

    Context 'When PAT validation fails' {
        BeforeAll {
            function Test-AzDevOpsPat {
                param (
                    [string]$Pat,
                    [bool]$IsValid
                )
                return $false
            }
        }

        It 'Should throw an error if PAT is invalid' {
            $params = @{
                Organization = "contoso"
                ProjectId = "MyProject"
                PersonalAccessToken = "invalidPAT"
            }
            {
                & $functionName @params
            } | Should -Throw
        }
    }
}

