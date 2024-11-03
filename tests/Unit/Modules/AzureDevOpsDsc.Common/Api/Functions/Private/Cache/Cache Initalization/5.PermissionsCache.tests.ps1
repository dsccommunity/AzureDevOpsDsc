$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_5_PermissionsCache Tests' -Tags "Unit", "Cache" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath '5.PermissionsCache.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName List-DevOpsSecurityNamespaces -MockWith {
            return @(
                [PSCustomObject]@{ name = 'Namespace1'; namespaceId = 1; writePermission = $true; readPermission = $true; dataspaceCategory = 'category1'; actions = @('Action1','Action2') },
                [PSCustomObject]@{ name = 'Namespace2'; namespaceId = 2; writePermission = $false; readPermission = $true; dataspaceCategory = 'category2'; actions = @('Action3','Action4') }
            )
        }

        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

        $global:DSCAZDO_OrganizationName = "DefaultOrg"

    }

    It 'Uses provided OrganizationName parameter' {
        AzDoAPI_5_PermissionsCache -OrganizationName 'TestOrg'
        Assert-VerifiableMock
    }

    It 'Uses global OrganizationName when parameter is not provided' {
        AzDoAPI_5_PermissionsCache
        Assert-MockCalled -CommandName List-DevOpsSecurityNamespaces -ParameterFilter { $OrganizationName -eq $global:DSCAZDO_OrganizationName }
    }

    It 'Adds each security namespace to cache correctly' {
        AzDoAPI_5_PermissionsCache -OrganizationName 'TestOrg'

        Assert-MockCalled -CommandName Add-CacheItem -Times 2
        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter { $Key -eq 'Namespace1' -and $Type -eq 'SecurityNamespaces' }
        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter { $Key -eq 'Namespace2' -and $Type -eq 'SecurityNamespaces' }
    }

    It 'Exports cache correctly' {
        AzDoAPI_5_PermissionsCache -OrganizationName 'TestOrg'

        Assert-MockCalled -CommandName Export-CacheObject -ParameterFilter { $CacheType -eq 'SecurityNameSpaces' -and $Depth -eq 5 }
    }
}
