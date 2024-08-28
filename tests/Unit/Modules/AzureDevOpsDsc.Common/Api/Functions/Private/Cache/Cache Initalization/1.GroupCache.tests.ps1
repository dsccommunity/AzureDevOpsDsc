$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_1_GroupCache' -Tags "Unit", "Cache" {


    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath '1.GroupCache.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName List-DevOpsGroups -MockWith {
            return @(
                [pscustomobject]@{ PrincipalName = 'Group1'; Id = 1 },
                [pscustomobject]@{ PrincipalName = 'Group2'; Id = 2 }
            )
        }

        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    Context 'When OrganizationName is provided' {

        It 'should call List-DevOpsGroups with the correct parameters' {
            AzDoAPI_1_GroupCache -OrganizationName 'MyOrganization'

            Assert-MockCalled List-DevOpsGroups -Exactly -Times 1 -Scope It -ParameterFilter {
                $Organization -eq 'MyOrganization'
            }
        }

        It 'should add groups to the cache' {
            AzDoAPI_1_GroupCache -OrganizationName 'MyOrganization'

            Assert-MockCalled Add-CacheItem -Exactly -Times 2 -Scope It -ParameterFilter {
                ($Key -eq 'Group1' -and $Value.PrincipalName -eq 'Group1') -or
                ($Key -eq 'Group2' -and $Value.PrincipalName -eq 'Group2')
            }
        }

        It 'should export the cache' {
            AzDoAPI_1_GroupCache -OrganizationName 'MyOrganization'

            Assert-MockCalled Export-CacheObject -Exactly -Times 1 -Scope It -ParameterFilter {
                $CacheType -eq 'LiveGroups' -and $Content -eq $global:AzDoLiveGroups
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
            AzDoAPI_1_GroupCache

            Assert-MockCalled List-DevOpsGroups -Exactly -Times 1 -Scope It -ParameterFilter {
                $Organization -eq 'GlobalOrganization'
            }
        }
    }

    Context 'Error handling' {

        It 'should handle errors during API call' {
            Mock -CommandName List-DevOpsGroups -MockWith { throw "API Error" }
            Mock -CommandName Write-Error -Verifiable

            { AzDoAPI_1_GroupCache -OrganizationName 'MyOrganization' } | Should -Not -Throw
            Assert-VerifiableMock
        }

        It 'should handle errors during cache export' {
            Mock -CommandName Export-CacheObject -MockWith { throw "Export failed" }
            Mock -CommandName Write-Error -Verifiable

            { AzDoAPI_1_GroupCache -OrganizationName 'MyOrganization' } | Should -Not -Throw
            Assert-VerifiableMock
        }
    }
}
