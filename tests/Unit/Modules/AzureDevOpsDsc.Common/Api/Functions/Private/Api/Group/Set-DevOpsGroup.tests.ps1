powershell
Describe 'Set-DevOpsGroup' {
    Mock Get-AzDevOpsApiVersion {
        return "6.0-preview"
    }

    Mock Invoke-AzDevOpsApiRestMethod {
        @{
            id = "12345"
            displayName = "MockGroup"
            description = "Mock description"
        }
    }

    Context 'When called with Default Parameter Set' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $ApiUri = "https://dev.azure.com/contoso"
            $GroupName = "MyGroup"
            $GroupDescription = "Updated group description"
            $GroupDescriptor = "vssgp.MYGROUP"

            Set-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription -GroupDescriptor $GroupDescriptor

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $_.Uri -eq "$ApiUri/_apis/graph/groups/$GroupDescriptor?api-version=6.0-preview" -and
                $_.Method -eq 'Patch' -and
                $_.ContentType -eq 'application/json-patch+json' -and
                $_.Body -match '"path":"/displayName","value":"MyGroup"' -and
                $_.Body -match '"path":"/description","value":"Updated group description"'
            }
        }
    }

    Context 'When called with ProjectScope Parameter Set' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters and ProjectScopeDescriptor' {
            $ApiUri = "https://dev.azure.com/contoso"
            $GroupName = "MyProjectGroup"
            $GroupDescription = "Project group description"
            $ProjectScopeDescriptor = "vspgp.MYPROJECT"

            Set-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription -ProjectScopeDescriptor $ProjectScopeDescriptor

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $_.Uri -eq "$ApiUri/_apis/graph/groups?scopeDescriptor=$ProjectScopeDescriptor&api-version=6.0-preview" -and
                $_.Method -eq 'Patch' -and
                $_.ContentType -eq 'application/json-patch+json' -and
                $_.Body -match '"path":"/displayName","value":"MyProjectGroup"' -and
                $_.Body -match '"path":"/description","value":"Project group description"'
            }
        }
    }

    Context 'When an exception occurs during REST method invocation' {
        It 'Should catch the exception and write error' {
            Mock Invoke-AzDevOpsApiRestMethod { throw "Mocked exception" }

            $ApiUri = "https://dev.azure.com/contoso"
            $GroupName = "MyGroup"
            $GroupDescriptor = "vssgp.MYGROUP"
            $null = Set-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescriptor $GroupDescriptor 

            $errorMessage = "Failed to create group: Mocked exception"
            Assert-MockCalled Write-Error -Exactly -Times 1 -Scope It -ParameterFilter { $_ -eq $errorMessage }
        }
    }
}

