powershell
Describe "Set-xAzDoOrganizationGroup Tests" {
    Mock -CommandName Set-DevOpsGroup
    Mock -CommandName Remove-CacheItem
    Mock -CommandName Add-CacheItem
    Mock -CommandName Set-CacheObject

    $params = @{
        GroupName        = "MyGroup"
        GroupDescription = "MyGroupDescription"
        LookupResult     = @{
            Status     = [DSCGetSummaryState]::Current
            liveCache  = @{
                descriptor   = "desc123"
                principalName = "oldPrincipalName"
            }
            localCache = @{
                principalName = "localPrincipalName"
            }
        }
        Ensure = $null
        Force  = $false
    }

    It "Should warn and return when the group has been renamed" {
        $params.LookupResult.Status = [DSCGetSummaryState]::Renamed
        
        $result = Set-xAzDoOrganizationGroup @params
    
        Assert-MockCalled Write-Warning -Exactly -Times 1 -Scope It
        $result | Should -BeNullOrEmpty
    }

    It "Should call Set-DevOpsGroup with correct params" {
        $params.LookupResult.Status = [DSCGetSummaryState]::Current

        $result = Set-xAzDoOrganizationGroup @params

        Assert-MockCalled Set-DevOpsGroup -Exactly -Times 1 -ParameterFilter {
            $_.ApiUri -eq "https://vssps.dev.azure.com/" + $Global:DSCAZDO_OrganizationName -and
            $_.GroupName -eq "MyGroup" -and
            $_.GroupDescription -eq "MyGroupDescription" -and
            $_.GroupDescriptor -eq "desc123"
        }
    }

    It "Should update live cache correctly" {
        $params.LookupResult.Status = [DSCGetSummaryState]::Current

        $result = Set-xAzDoOrganizationGroup @params

        Assert-MockCalled Remove-CacheItem -ParameterFilter { $_.Key -eq "oldPrincipalName" -and $_.Type -eq 'LiveGroups' }
        Assert-MockCalled Add-CacheItem -ParameterFilter { $_.Key -eq "MyGroup" -and $_.Type -eq 'LiveGroups' }
        Assert-MockCalled Set-CacheObject -ParameterFilter { $_.CacheType -eq 'LiveGroups' }
    }

    It "Should update local cache correctly" {
        $params.LookupResult.Status = [DSCGetSummaryState]::Current

        $result = Set-xAzDoOrganizationGroup @params

        Assert-MockCalled Remove-CacheItem -ParameterFilter { $_.Key -eq "localPrincipalName" -and $_.Type -eq 'Groups' }
        Assert-MockCalled Add-CacheItem -ParameterFilter { $_.Key -eq "MyGroup" -and $_.Type -eq 'Groups' }
        Assert-MockCalled Set-CacheObject -ParameterFilter { $_.CacheType -eq 'Groups' }
    }

    It "Should throw if Set-DevOpsGroup throws" {
        Mock Set-DevOpsGroup { throw "API Error" } -Verifiable -VerifiableBehavior Strict

        { Set-xAzDoOrganizationGroup @params } | Should -Throw "API Error"
    }
}

