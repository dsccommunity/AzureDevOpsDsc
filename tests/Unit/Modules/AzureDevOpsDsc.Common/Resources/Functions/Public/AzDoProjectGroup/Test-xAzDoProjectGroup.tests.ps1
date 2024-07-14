powershell
Describe 'Test-xAzDoProjectGroup' {
    
    Mock -CommandName 'Format-AzDoGroup' {
        return "groupKey"
    }
    
    Mock -CommandName 'Get-CacheItem' {
        param ($Key, $Type)
        if ($Key -eq "groupKey" -and $Type -eq 'LiveGroups') {
            return $true
        }
        return $false
    }

    Context 'When parameters are valid' {
        It 'Should return true when group is found in cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Unchanged
                Current = @{ description = 'Group Description' }
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return false when group name and description matches' {
            $GroupName = 'TestGroup'
            $GroupDescription = 'Group Description'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Unchanged
                Current = @{ description = $GroupDescription }
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -GetResult $GetResult
            $result | Should -BeFalse
        }

        It 'Should return true when status is Changed and group present in both live and cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Changed
                Current = @{}
                Cache = @{}
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return true when status is Changed and group present in live but not cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Changed
                Current = @{}
                Cache = $null
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return true when status is Changed and group not present in live but in cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Changed
                Current = $null
                Cache = @{}
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return false when status is Renamed' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Renamed
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeFalse
        }

        It 'Should return true when group present in cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Missing
            }

            $result = Test-xAzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }
    }
}

