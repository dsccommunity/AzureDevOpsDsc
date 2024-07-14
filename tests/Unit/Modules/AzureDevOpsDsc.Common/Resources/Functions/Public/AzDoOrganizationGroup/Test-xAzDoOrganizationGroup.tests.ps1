
# Mocked function - simulating Azure DevOps API call
Function Test-xAzDoOrganizationGroup {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Pat,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiUri
    )

    # Simulated logic - this will be mocked during Pester tests
    if ($GroupName -eq 'ExistingGroup') {
        return $true
    } else {
        return $false
    }
}

# Pester tests
Describe "Test-xAzDoOrganizationGroup" {

    Context "when the group exists" {
        It "should return true" {
            # Mock Test-xAzDoOrganizationGroup function to simulate group existence
            Mock -CommandName Test-xAzDoOrganizationGroup -MockWith { return $true }

            $result = Test-xAzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg'
            $result | Should -Be $true
        }
    }

    Context "when the group does not exist" {
        It "should return false" {
            # Mock Test-xAzDoOrganizationGroup function to simulate group non-existence
            Mock -CommandName Test-xAzDoOrganizationGroup -MockWith { return $false }

            $result = Test-xAzDoOrganizationGroup -GroupName 'NonExistentGroup' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg'
            $result | Should -Be $false
        }
    }

    Context "when there is an empty GroupName parameter" {
        It "should throw an error" {
            { Test-xAzDoOrganizationGroup -GroupName '' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg' } | Should -Throw
        }
    }

    Context "when there is an empty Pat parameter" {
        It "should throw an error" {
            { Test-xAzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat '' -ApiUri 'https://dev.azure.com/myorg' } | Should -Throw
        }
    }

    Context "when there is an empty ApiUri parameter" {
        It "should throw an error" {
            { Test-xAzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat 'dummyPat' -ApiUri '' } | Should -Throw
        }
    }

}

