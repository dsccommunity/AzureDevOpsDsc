Describe "Format-AzDoProjectName Tests" {
    It "Formats a group name with '%ORG%' correctly" {
        { Format-AzDoProjectName -GroupName "%ORG%\Developers" -OrganizationName "Contoso" } | Should -Not -Throw
        $result = Format-AzDoProjectName -GroupName "%ORG%\Developers" -OrganizationName "Contoso"
        $result | Should -Be "[Contoso]\Developers"
    }

    It "Formats a group name with '%TFS%' correctly" {
        { Format-AzDoProjectName -GroupName "%TFS%\QA" -OrganizationName "Contoso" } | Should -Not -Throw
        $result = Format-AzDoProjectName -GroupName "%TFS%\QA" -OrganizationName "Contoso"
        $result | Should -Be "[TEAM FOUNDATION]\QA"
    }

    It "Formats a regular group name correctly" {
        { Format-AzDoProjectName -GroupName "ProjectX\TeamA" -OrganizationName "Contoso" } | Should -Not -Throw
        $result = Format-AzDoProjectName -GroupName "ProjectX\TeamA" -OrganizationName "Contoso"
        $result | Should -Be "[ProjectX]\TeamA"
    }

    It "Throws an exception if the group name does not contain a backslash" {
        { Format-AzDoProjectName -GroupName "InvalidGroupName" -OrganizationName "Contoso" } | Should -Throw
    }

    It "Throws an exception if the group name is correct but the second part is empty" {
        { Format-AzDoProjectName -GroupName "ProjectX\" -OrganizationName "Contoso" } | Should -Throw
    }
}

# To run the tests, you would typically call Invoke-Pester from the command line:
# Invoke-Pester -Script .\Tests\FormatAzDoProject.Tests.ps1
