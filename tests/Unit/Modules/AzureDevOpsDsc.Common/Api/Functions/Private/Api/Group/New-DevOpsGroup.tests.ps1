
Describe "New-DevOpsGroup" {
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            displayName = $GroupName
            description = $GroupDescription
            id = "mock-id"
        }
    }
    Mock Get-AzDevOpsApiVersion {
        return "6.0"
    }

    Context "When required parameters are provided" {
        It 'Creates a new group successfully' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"

            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
            $result.displayName | Should -Be $GroupName
        }
    }

    Context "When optional parameters are provided" {
        It 'Creates a new group successfully with description' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"
            $GroupDescription = "A sample group"

            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -GroupDescription $GroupDescription

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
            $result.description | Should -Be $GroupDescription
        }

        It 'Creates a new group successfully with project scope descriptor' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"
            $ProjectScopeDescriptor = "vstfs:///Classification/TeamProject/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

            $result = New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName -ProjectScopeDescriptor $ProjectScopeDescriptor

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
            $result.displayName | Should -Be $GroupName
        }
    }

    Context "When an exception is thrown" {
        Mock Invoke-AzDevOpsApiRestMethod {
            throw "API call failed"
        }

        It 'Handles the error and writes an error message' {
            $ApiUri = "https://dev.azure.com/myorganization"
            $GroupName = "MyGroup"

            { New-DevOpsGroup -ApiUri $ApiUri -GroupName $GroupName } | Should -Throw
        }
    }
}

