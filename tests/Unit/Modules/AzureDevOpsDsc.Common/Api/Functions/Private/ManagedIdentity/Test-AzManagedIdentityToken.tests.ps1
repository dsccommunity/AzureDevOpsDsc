Describe 'Test-Token' {
    Mock Invoke-AzDevOpsApiRestMethod { return $null }

    BeforeAll {
        # Set a global variable that the function uses to construct the URL
        $GLOBAL:DSCAZDO_OrganizationName = "ContosoOrg"
    }

    It 'Returns true when the managed identity token is valid' {
        # Simulate a valid token object with a Get method
        $validToken = New-Object psobject -Property @{
            Get = { "fake-valid-token" }
        }

        $result = Test-Token -ManagedIdentity $validToken
        $result | Should -Be $true
    }

    It 'Returns false when the managed identity token is invalid' {
        # Simulate an invalid token object with a Get method
        $invalidToken = New-Object psobject -Property @{
            Get = { "fake-invalid-token" }
        }

        # Simulate the API call failure
        Mock Invoke-AzDevOpsApiRestMethod { throw "Unauthorized" }

        $result = Test-Token -ManagedIdentity $invalidToken
        $result | Should -Be $false
    }
}

