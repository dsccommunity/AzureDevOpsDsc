$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_0_ProjectCache' {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName List-DevOpsProjects -MockWith {
            param ($Organization)
            return @(
                [pscustomobject]@{ Id = 1; Name = 'Project1' },
                [pscustomobject]@{ Id = 2; Name = 'Project2' }
            )
        }

        Mock -CommandName Get-DevOpsSecurityDescriptor -MockWith {
            param ($ProjectId, $Organization)
            return "SecurityDescriptor for Project $ProjectId"
        }

        Mock -CommandName Add-CacheItem -MockWith {
            param ($Key, $Value, $Type)
        }

        Mock -CommandName Export-CacheObject -MockWith {
            param ($CacheType, $Content)
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0' }

    }

    Context 'When OrganizationName is provided' {

        It 'should call List-DevOpsProjects with the correct parameters' {
            AzDoAPI_0_ProjectCache -OrganizationName 'MyOrganization'

            Assert-MockCalled List-DevOpsProjects -Exactly -Times 1
        }

        It 'should add projects to the cache' {
            AzDoAPI_0_ProjectCache -OrganizationName 'MyOrganization'

            Assert-MockCalled Add-CacheItem -Exactly -Times 2 -ParameterFilter {
                ($Key -eq 'Project1' -and $Value.Name -eq 'Project1') -or
                ($Key -eq 'Project2' -and $Value.Name -eq 'Project2')
            }
        }

        It 'should export the cache' {
            AzDoAPI_0_ProjectCache -OrganizationName 'MyOrganization'

            Assert-MockCalled Export-CacheObject -Exactly -Times 1 -ParameterFilter {
                ($CacheType -eq 'LiveProjects') -and
                ($Content -eq $global:AzDoLiveProjects)
            }
        }
    }

    Context 'When OrganizationName is not provided' {

        Mock -CommandName Write-Verbose -MockWith {
            param ($Message)
        }

        BeforeAll {
            $Global:DSCAZDO_OrganizationName = 'GlobalOrganization'
        }

        It 'should use the global variable for organization name' {
            AzDoAPI_0_ProjectCache

            Assert-MockCalled List-DevOpsProjects -Exactly -Times 1
        }
    }

    Context 'Error handling' {

        It 'should handle errors during API call' {
            Mock -CommandName List-DevOpsProjects -MockWith { throw "API Error" }
            Mock -CommandName Write-Error -Verifiable

            { AzDoAPI_0_ProjectCache -OrganizationName 'MyOrganization' } | Should -Not -Throw
        }

        It 'should handle errors during cache export' {
            Mock -CommandName Export-CacheObject -MockWith { throw "Export failed" }
            Mock -CommandName Write-Error -Verifiable

            { AzDoAPI_0_ProjectCache -OrganizationName 'MyOrganization' } | Should -Not -Throw
        }
    }
}
