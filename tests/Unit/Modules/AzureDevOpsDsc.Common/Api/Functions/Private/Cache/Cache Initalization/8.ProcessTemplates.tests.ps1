Describe 'AzDoAPI_8_ProjectProcessTemplates' {
    $mockOrganizationName = 'TestOrg'
    $mockProcesses = @(
        [PSCustomObject]@{ name = 'Process1' },
        [PSCustomObject]@{ name = 'Process2' }
    )

    BeforeAll {
        Export-ModuleMember -Function AzDoAPI_8_ProjectProcessTemplates
        $script:global:DSCAZDO_OrganizationName = 'DefaultOrg'
    }

    Mock List-DevOpsProcess {
        param($param) $mockProcesses
    }

    Mock Add-CacheItem
    Mock Export-CacheObject

    Context 'When OrganizationName parameter is provided' {
        It 'should call List-DevOpsProcess with provided OrganizationName' {
            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            Assert-MockCalled List-DevOpsProcess -ParameterFilter { $Organization -eq $mockOrganizationName } -Exactly 1
        }

        It 'should add processes to cache' {
            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            $mockProcesses | ForEach-Object {
                Assert-MockCalled Add-CacheItem -ParameterFilter { $Key -eq $_.name -and $Value -eq $_ -and $Type -eq 'LiveProcesses' } -Exactly 1
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
            Mock List-DevOpsProcess { throw 'An error occurred' }
            Mock Write-Error

            AzDoAPI_8_ProjectProcessTemplates -OrganizationName $mockOrganizationName

            Assert-MockCalled Write-Error -ParameterFilter { $_.Message -eq 'An error occurred' } -Exactly 1
        }
    }
}

