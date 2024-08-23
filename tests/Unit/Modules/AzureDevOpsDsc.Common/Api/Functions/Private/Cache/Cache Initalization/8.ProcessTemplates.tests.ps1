$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_8_ProjectProcessTemplates' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath '8.ProcessTemplates.tests'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        $mockOrganizationName = 'TestOrg'
        $mockProcesses = @(
            [PSCustomObject]@{ name = 'Process1' },
            [PSCustomObject]@{ name = 'Process2' }
        )

        $script:global:DSCAZDO_OrganizationName = 'DefaultOrg'

        Mock -CommandName List-DevOpsProcess -MockWith {
            param($param) $mockProcesses
        }

        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    Context 'When OrganizationName parameter is provided' {
        It 'should call List-DevOpsProcess with provided OrganizationName' {
            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            Assert-MockCalled List-DevOpsProcess -ParameterFilter { $Organization -eq $mockOrganizationName } -Exactly 1
        }

        It 'should add processes to cache' {
            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            $mockProcesses | ForEach-Object {
                Assert-MockCalled Add-CacheItem -ParameterFilter {
                    $Key -eq $_.name -and
                    $Value -eq $_ -and
                    $Type -eq 'LiveProcesses'
                } -Exactly 1
            }
        }

        It 'should export cache' {
            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            Assert-MockCalled Export-CacheObject -ParameterFilter { $CacheType -eq 'LiveProcesses' }
        }
    }

    Context 'When OrganizationName parameter is not provided' {
        It 'should call List-DevOpsProcess with global OrganizationName' {
            AzDoAPI_8_ProjectProcessTemplates

            Assert-MockCalled List-DevOpsProcess -ParameterFilter { $Organization -eq $global:DSCAZDO_OrganizationName } -Exactly 1
        }
    }

    Context 'When an error occurs during function execution' {
        It 'should catch and handle the error' {
            Mock -CommandName List-DevOpsProcess -MockWith { throw 'An error occurred' }
            Mock -CommandName Write-Error -Verifiable

            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            Assert-VerifiableMock
        }
    }
}
