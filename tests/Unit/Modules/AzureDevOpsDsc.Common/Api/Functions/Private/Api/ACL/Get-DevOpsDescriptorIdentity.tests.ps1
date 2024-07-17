powershell
# Import the Pester module
Import-Module Pester

# Mock the Invoke-AzDevOpsApiRestMethod function
Mock Invoke-AzDevOpsApiRestMethod {
    Write-Output @{
        value = @(
            @{
                displayName = "John Doe"
                principalName = "johndoe@contoso.com"
            }
        )
        count = 1
    }
}

Describe "Get-DevOpsDescriptorIdentity" {
    BeforeAll {
        # Define test parameters
        $organizationName = "TestOrg"
        $subjectDescriptor = "subject:abcd1234"
    }

    Context "when called with valid SubjectDescriptor" {
        It "should return a single identity" {
            # Run the function
            $result = Get-DevOpsDescriptorIdentity -OrganizationName $organizationName -SubjectDescriptor $subjectDescriptor

            # Assert results
            $result | Should -Not -BeNullOrEmpty
            $result.displayName | Should -Be "John Doe"
        }
    }

    Context "when SubjectDescriptor is not provided" {
        It "should return null" {
            # Run the function without SubjectDescriptor
            $result = Get-DevOpsDescriptorIdentity -OrganizationName $organizationName
            
            # Assert results
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context "when more than one identity is returned" {
        BeforeAll {
            Mock Invoke-AzDevOpsApiRestMethod {
                Write-Output @{
                    value = @(
                        @{
                            displayName = "John Doe"
                            principalName = "johndoe@contoso.com"
                        },
                        @{
                            displayName = "Jane Doe"
                            principalName = "janedoe@contoso.com"
                        }
                    )
                    count = 2
                }
            }
        }
        
        It "should return null" {
            # Run the function
            $result = Get-DevOpsDescriptorIdentity -OrganizationName $organizationName -SubjectDescriptor $subjectDescriptor

            # Assert results
            $result | Should -BeNullOrEmpty
        }
    }
}


