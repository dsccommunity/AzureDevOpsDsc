
Describe "Format-AzDoProjectName Tests" {

    # Test: Correct format with backslash
    It "Should format 'Project1\Group1' correctly" {
        $result = Format-AzDoProjectName -GroupName 'Project1\Group1' -OrganizationName 'Org')
        $result | Should -Be '[Project1]\Group1'
    }

    # Test: Correct format with forward slash
    It "Should format 'Project1/Group1' correctly" {
        $result = Format-AzDoProjectName -GroupName 'Project1/Group1' -OrganizationName 'Org')
        $result | Should -Be '[Project1]\Group1'
    }

    # Test: Replace %ORG% with OrganizationName
    It "Should replace %ORG% with OrganizationName" {
        $result = Format-AzDoProjectName -GroupName '%ORG%\Group1' -OrganizationName 'Organization')
        $result | Should -Be '[Organization]\Group1'
    }

    # Test: Replace %TFS% with TEAM FOUNDATION
    It "Should replace %TFS% with TEAM FOUNDATION" {
        $result = Format-AzDoProjectName -GroupName '%TFS%\Group1' -OrganizationName 'Organization')
        $result | Should -Be '[TEAM FOUNDATION]\Group1'
    }

    # Test: Throw error on empty project name
    It "Should throw error on empty project name" {
        { Format-AzDoProjectName -GroupName '\Group1' -OrganizationName 'Organization' } | Should -Throw "The GroupName '\Group1' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName' or 'Project/GroupName."
    }

    # Test: Throw error on single element group name
    It "Should throw error on single element group name" {
        { Format-AzDoProjectName -GroupName 'Group1' -OrganizationName 'Organization' } | Should -Throw "The GroupName 'Group1' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName' or 'Project/GroupName."
    }

    # Test: Throw error on empty group name
    It "Should throw error on empty group name" {
        { Format-AzDoProjectName -GroupName 'Project\' -OrganizationName 'Organization' } | Should -Throw "The GroupName 'Project\' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName'."
    }
}

