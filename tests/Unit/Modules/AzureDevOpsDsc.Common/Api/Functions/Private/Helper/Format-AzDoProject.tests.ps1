Describe 'Format-AzDoProjectName' {
    Mock Write-Verbose

    Context 'When GroupName is already formatted' {
        It 'Returns the same GroupName' {
            $result = Format-AzDoProjectName -GroupName '[ProjectName]\GroupName' -OrganizationName 'OrgName'
            $result | Should -Be '[ProjectName]\GroupName'
        }
    }

    Context 'When GroupName needs formatting' {
        It 'Formats correctly with given organization name' {
            $result = Format-AzDoProjectName -GroupName 'ProjectName/GroupName' -OrganizationName 'OrgName'
            $result | Should -Be '[ProjectName]\GroupName'
        }

        It 'Throws if the given format has insufficient parts' {
            { Format-AzDoProjectName -GroupName 'GroupName' -OrganizationName 'OrgName' } | Should -Throw
        }

        It 'Replaces %ORG% with given organization name' {
            $result = Format-AzDoProjectName -GroupName '%ORG%\GroupName' -OrganizationName 'OrgName'
            $result | Should -Be '[OrgName]\GroupName'
        }

        It 'Replaces %TFS% with TEAM FOUNDATION' {
            $result = Format-AzDoProjectName -GroupName '%TFS%\GroupName' -OrganizationName 'OrgName'
            $result | Should -Be '[TEAM FOUNDATION]\GroupName'
        }

        It 'Throws if group part is empty' {
            { Format-AzDoProjectName -GroupName 'ProjectName\' -OrganizationName 'OrgName' } | Should -Throw
        }

        It 'Trims leading and trailing spaces' {
            $result = Format-AzDoProjectName -GroupName ' ProjectName / GroupName ' -OrganizationName 'OrgName'
            $result | Should -Be '[ProjectName]\GroupName'
        }
    }

    AfterEach {
        Remove-Mock Write-Verbose
    }
}

