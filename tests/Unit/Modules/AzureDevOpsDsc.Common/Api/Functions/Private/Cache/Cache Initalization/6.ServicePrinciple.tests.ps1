$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_6_ServicePrinciple' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName List-DevOpsServicePrinciples -MockWith {
            return @([PSCustomObject]@{ displayName = 'SP1' }, [PSCustomObject]@{ displayName = 'SP2' })
        }
        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

        $Global:DSCAZDO_OrganizationName = 'MyOrganization'
    }

    It 'should call List-DevOpsServicePrinciples with provided organization name' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName'

        Assert-MockCalled -CommandName List-DevOpsServicePrinciples -Exactly 1 -ParameterFilter {
            $OrganizationName -eq 'TestOrgName'
        }
    }

    It 'should call List-DevOpsServicePrinciples with global organization name if none provided' {
        AzDoAPI_6_ServicePrinciple

        Assert-MockCalled -CommandName List-DevOpsServicePrinciples -Exactly 1 -ParameterFilter {
            $OrganizationName -eq $Global:DSCAZDO_OrganizationName
        }
    }

    It 'should add returned service principals to cache' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName'

        Assert-MockCalled -CommandName Add-CacheItem -Exactly 2
        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
            $Key -eq 'SP1' -and
            $Value.displayName -eq 'SP1' -and
            $Type -eq 'LiveServicePrinciples'
        }
        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
            $Key -eq 'SP2' -and
            $Value.displayName -eq 'SP2' -and
            $Type -eq 'LiveServicePrinciples'
        }
    }

    It 'should export cache object after adding service principals' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName'

        Assert-MockCalled -CommandName Export-CacheObject -Exactly 1 -ParameterFilter { $CacheType -eq 'LiveServicePrinciples' }
    }

    It 'should write an error message if an exception occurs' {
        Mock -CommandName List-DevOpsServicePrinciples -MockWith { throw 'API Error' }
        Mock -CommandName Write-Error -Verifiable

        { AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrgName' } | Should -Not -Throw

        Assert-MockCalled -CommandName Write-Error -Exactly 1
        Assert-VerifiableMock
    }
}
