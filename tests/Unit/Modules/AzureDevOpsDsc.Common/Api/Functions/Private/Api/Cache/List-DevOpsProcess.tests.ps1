powershell
Describe 'List-DevOpsProcess' {
    Param (
        [string]$Organization = "TestOrg",
        [string]$ApiVersion = "6.0-preview.1"
    )

    Mock Get-AzDevOpsApiVersion { "6.0-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod { 
        return @{
            value = @(
                @{ name = "Agile" },
                @{ name = "Scrum" }
            )
        }
    }

    It 'Returns processes when provided valid organization' {
        $result = List-DevOpsProcess -Organization $Organization
        $result | Should -Not -BeNullOrEmpty
        $result | Should -Contain @{
            name = "Agile"
        }
        $result | Should -Contain @{
            name = "Scrum"
        }
    }

    It 'Uses default ApiVersion when not provided' {
        List-DevOpsProcess -Organization $Organization
        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1 -Scope It
    }

    It 'Returns null when no processes are present' {
        Mock Invoke-AzDevOpsApiRestMethod { return @{ value = @() } }
        $result = List-DevOpsProcess -Organization $Organization
        $result | Should -BeNull
    }

    It 'Calls Invoke-AzDevOpsApiRestMethod with correct parameters' {
        List-DevOpsProcess -Organization $Organization -ApiVersion $ApiVersion
        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
            $params.Uri -eq "https://dev.azure.com/TestOrg/_apis/process/processes?api-version=6.0-preview.1"
        }
    }
}

