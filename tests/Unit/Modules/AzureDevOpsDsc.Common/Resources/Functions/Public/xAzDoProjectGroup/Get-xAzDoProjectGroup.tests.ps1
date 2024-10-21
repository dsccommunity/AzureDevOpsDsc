$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-AzDoProjectGroup' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzDoProjectGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')

        $mockProjectName = "TestProject"
        $mockGroupName = "TestGroup"
        $mockDescription = "TestDescription"

        Mock -CommandName Test-AzDevOpsProjectName -MockWith { return $true }
        Mock -CommandName Get-CacheItem -MockWith {
            switch ($Type) {
                'LiveProjects' { return @{ originId = 1 } }
                'LiveGroups' { return @{ originId = 1 } }
                'Group' { return @{ originId = 1 } }
            }
        }
        Mock -CommandName Remove-CacheItem
        Mock -CommandName Add-CacheItem
        Mock -CommandName Format-AzDoGroup -MockWith {
            return ('{0}:{1}' -f $mockProjectName, $mockGroupName)
        }

    }

    It 'should call Get-CacheItem for livegroup lookup' {
        Get-AzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName
        Assert-MockCalled Get-CacheItem -ParameterFilter {
            $Key -eq "$mockProjectName" -and $Type -eq 'LiveProjects'
        } -Times 1
    }

    It 'should return correct status when livegroup and localgroup originId differ' {

        Mock -CommandName Get-CacheItem -MockWith { return @{ originId = 1 } } -ParameterFilter {
            $Type -eq 'LiveGroups'
        }
        Mock -CommandName Get-CacheItem -MockWith { return @{ originId = 2 } } -ParameterFilter {
            $Type -eq 'Group'
        }
        Mock -CommandName Find-CacheItem -MockWith { return @{ originId = 1 } }

        Mock -CommandName Format-AzDoGroup -MockWith {
            return ('{0}:{1}' -f $mockProjectName, $mockGroupName)
        }

        $result = Get-AzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName

        $result.status | Should -Be 'Renamed'
    }

    It 'should return status NotFound when livegroup is absent but localgroup is present' {
        Mock -CommandName Get-CacheItem -MockWith {
            param ($Key, $Type)
            if ($Type -eq 'LiveGroups') { return $null }
            if ($Type -eq 'Group') { return @{originId = 1} }
        }

        Mock -CommandName Format-AzDoGroup -MockWith {
            return ('{0}:{1}' -f $mockProjectName, $mockGroupName)
        }

        $result = Get-AzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName

        $result.status | Should -Be 'NotFound'
    }

    It 'should return status Changed when properties differ' {
        Mock -CommandName Get-CacheItem -MockWith {
            return @{description = 'OldDescription'; name = $mockGroupName; originId = 1}
        }
        Mock -CommandName Format-AzDoGroup -MockWith {
            return ('{0}:{1}' -f $mockProjectName, $mockGroupName)
        }

        $result = Get-AzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName -GroupDescription $mockDescription

        $result.status | Should -Be 'Changed'
        $result.propertiesChanged | Should -Contain 'description'
    }

    It 'should return status Unchanged when properties are same' {
        Mock -CommandName Get-CacheItem -MockWith {
            return @{description = $mockDescription; name = $mockGroupName; originId = 1}
        }
        Mock -CommandName Format-AzDoGroup -MockWith {
            return ('{0}:{1}' -f $mockProjectName, $mockGroupName)
        }

        $result = Get-AzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName -GroupDescription $mockDescription

        $result.status | Should -Be 'Unchanged'
    }

    It 'should add current livegroup to cache if localgroup was not present' {

        Mock -CommandName Get-CacheItem -MockWith {
            if ($Type -eq 'LiveGroups') {
                return @{
                    description = $mockDescription
                    displayName = $mockGroupName
                    originId = 1
                }
            }
            elseif ($Type -eq 'Group') {
                return $null
            }
            else {
                return $null
            }
        }

        Mock -CommandName Format-AzDoGroup -MockWith {
            return ('{0}:{1}' -f $mockProjectName, $mockGroupName)
        }

        Get-AzDoProjectGroup -ProjectName $mockProjectName -GroupName $mockGroupName -GroupDescription $mockDescription

        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
            ($Key -eq ('{0}:{1}' -f $mockProjectName, $mockGroupName)) -and ($Type -eq 'Group')
        } -Times 1
    }
}
