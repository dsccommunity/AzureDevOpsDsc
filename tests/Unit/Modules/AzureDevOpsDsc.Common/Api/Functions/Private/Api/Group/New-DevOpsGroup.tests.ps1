powershell
Describe 'New-DevOpsGroup' {
    $ApiUri = "https://dev.azure.com/myorganization"
    $GroupName = "MyGroup"
    $GroupDescription = "A description of MyGroup"
    $ApiVersion = "5.0"
    $ProjectScopeDescriptor = "vstfs:///Classification/TeamProject/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $ExpectedUri = "$ApiUri/_apis/graph/groups?api-version=$ApiVersion"
    $ExpectedUriWithScope = "$ApiUri/_apis/graph/groups?scopeDescriptor=$ProjectScopeDescriptor&api-version=$ApiVersion"

    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            displayName = $using:GroupName
            description = $using:GroupDescription
        }
    }

    Context 'without ProjectScopeDescriptor' {
        It 'should call Invoke-AzDevOpsApiRestMethod with the correct parameters' {
            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription -ApiVersion $ApiVersion

            $params = @{
                Uri = $ExpectedUri
                Method = 'Post'
                ContentType = 'application/json'
                Body = @{
                    displayName = $GroupName
                    description = $GroupDescription
                } | ConvertTo-Json
            }

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $_.Uri -eq $params.Uri -and
                $_.Method -eq $params.Method -and
                $_.ContentType -eq $params.ContentType -and
                $_.Body -eq $params.Body
            }

            $result.displayName | Should -Be $GroupName
            $result.description | Should -Be $GroupDescription
        }
    }

    Context 'with ProjectScopeDescriptor' {
        It 'should call Invoke-AzDevOpsApiRestMethod with the correct parameters including scope descriptor' {
            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription -ApiVersion $ApiVersion -ProjectScopeDescriptor $ProjectScopeDescriptor

            $params = @{
                Uri = $ExpectedUriWithScope
                Method = 'Post'
                ContentType = 'application/json'
                Body = @{
                    displayName = $GroupName
                    description = $GroupDescription
                } | ConvertTo-Json
            }

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $_.Uri -eq $params.Uri -and
                $_.Method -eq $params.Method -and
                $_.ContentType -eq $params.ContentType -and
                $_.Body -eq $params.Body
            }

            $result.displayName | Should -Be $GroupName
            $result.description | Should -Be $GroupDescription
        }
    }

    Context 'when Invoke-AzDevOpsApiRestMethod throws an exception' {
        Mock Invoke-AzDevOpsApiRestMethod { throw "API call failed" }

        It 'should write an error message and not return a result' {
            { New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription -ApiVersion $ApiVersion -ProjectScopeDescriptor $ProjectScopeDescriptor } | Should -Throw

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It
        }
    }
}

