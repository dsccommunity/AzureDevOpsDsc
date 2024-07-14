
Describe 'AzDoAPI_6_ServicePrinciple' {
    BeforeAll {
        function List-DevOpsServicePrinciples {
            param(
                [Parameter()]
                [string]$Organization
            )
            return @( [pscustomobject]@{ DisplayName = 'ServicePrincipal1' }, [pscustomobject]@{ DisplayName = 'ServicePrincipal2' } )
        }

        function Add-CacheItem {
            param(
                [Parameter()]
                [string]$Key,
                [Parameter()]
                [object]$Value,
                [Parameter()]
                [string]$Type
            )
        }

        function Export-CacheObject {
            param(
                [Parameter()]
                [string]$CacheType,
                [Parameter()]
                [object]$Content
            )
        }

        $Global:DSCAZDO_OrganizationName = 'DefaultOrg'
    }

    BeforeEach {
        Mock List-DevOpsServicePrinciples {
            param($params)
            return @( [pscustomobject]@{ DisplayName = 'ServicePrincipal1' }, [pscustomobject]@{ DisplayName = 'ServicePrincipal2' } )
        }

        Mock Add-CacheItem
        Mock Export-CacheObject
    }

    It 'Should use the OrganizationName parameter if provided' {
        $OrganizationName = 'TestOrg'
        AzDoAPI_6_ServicePrinciple -OrganizationName $OrganizationName

        Assert-MockCalled List-DevOpsServicePrinciples -ParameterFilter {
            $Organization -eq 'TestOrg'
        } -Times 1
    }

    It 'Should use the global variable DSCAZDO_OrganizationName if no parameter is provided' {
        AzDoAPI_6_ServicePrinciple

        Assert-MockCalled List-DevOpsServicePrinciples -ParameterFilter {
            $Organization -eq 'DefaultOrg'
        } -Times 1
    }

    It 'Should add returned service principals to the cache' {
        $servicePrincipals = @( [pscustomobject]@{ DisplayName = 'ServicePrincipal1' }, [pscustomobject]@{ DisplayName = 'ServicePrincipal2' } )
        Mock List-DevOpsServicePrinciples { return $servicePrincipals }

        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrg'

        Assert-MockCalled Add-CacheItem -ParameterFilter {
            $Key -eq 'ServicePrincipal1' -or $Key -eq 'ServicePrincipal2'
        } -Times 2
    }

    It 'Should call Export-CacheObject with the right CacheType' {
        AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrg'

        Assert-MockCalled Export-CacheObject -ParameterFilter {
            $CacheType -eq 'LiveServicePrinciples'
        } -Times 1
    }

    It 'Should catch and write an error when an exception occurs' {
        Mock List-DevOpsServicePrinciples { throw "An error occurred" }

        { AzDoAPI_6_ServicePrinciple -OrganizationName 'TestOrg' } | Should -Throw

        Assert-MockCalled -ModuleName Microsoft.PowerShell.Utility -CommandName Write-Error
    }
}

