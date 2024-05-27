Describe "Format-AzDoProjectName Tests" {
    Context "Valid inputs" {
        It "Returns correctly formatted group name with valid input using backslash" {
            $result = Format-AzDoProjectName -GroupName "Project\Developers" -OrganizationName "Contoso"
            $result | Should -Be "[Project]\Developers"
        }

        It "Returns correctly formatted group name with valid input using forward slash" {
            $result = Format-AzDoProjectName -GroupName "Project/Developers" -OrganizationName "Contoso"
            $result | Should -Be "[Project]\Developers"
        }
    }

    Context "Special placeholders" {
        It "Replaces '%ORG%' with the organization name" {
            $result = Format-AzDoProjectName -GroupName "%ORG%\Developers" -OrganizationName "Contoso"
            $result | Should -Be "[Contoso]\Developers"
        }

        It "Replaces '%TFS%' with 'TEAM FOUNDATION'" {
            $result = Format-AzDoProjectName -GroupName "%TFS%\Developers" -OrganizationName "Contoso"
            $result | Should -Be "[TEAM FOUNDATION]\Developers"
        }
    }

    Context "Input errors" {
        It "Throws an exception if the group name does not contain a delimiter" {
            { Format-AzDoProjectName -GroupName "InvalidGroupName" -OrganizationName "Contoso" } | Should -Throw -ExpectedMessage "The GroupName 'InvalidGroupName' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName' or 'Project/GroupName."
        }

        It "Throws an exception if the project name part is empty" {
            { Format-AzDoProjectName -GroupName "\Developers" -OrganizationName "Contoso" } | Should -Throw -ExpectedMessage "The GroupName '\Developers' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName'."
        }

        It "Throws an exception if the group name part is empty" {
            { Format-AzDoProjectName -GroupName "Project\" -OrganizationName "Contoso" } | Should -Throw -ExpectedMessage "The GroupName 'Project\' is not in the correct format. The GroupName must be in the format 'ProjectName\GroupName'."
        }
    }
}


