
Describe 'Get-AzDevOpsProject' {
    Param (
        [string]$ApiUri = 'https://dev.azure.com/test_org/_apis/',
        [string]$Pat = 'fake_pat',
        [string]$ProjectId = 'fake_project_id',
        [string]$ProjectName = 'fake_project_name'
    )

    Mock Get-CacheItem {
        return @{
            Key = $ProjectName
            Value = @{
                ProjectId = $ProjectId
                ProjectName = $ProjectName
            }
        }
    }

    It 'Should return the project from cache when ProjectName is provided' {
        $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectName $ProjectName
        $result | Should -Not -BeNullOrEmpty
        $result.ProjectId | Should -Be $ProjectId
        $result.ProjectName | Should -Be $ProjectName
    }

    It 'Should validate the ApiUri' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['ApiUri'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $ApiUri
        $result | Should -Be $true
    }

    It 'Should validate the Pat' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['Pat'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $Pat
        $result | Should -Be $true
    }

    It 'Should validate the ProjectId' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['ProjectId'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $ProjectId
        $result | Should -Be $true
    }

    It 'Should validate the ProjectName' {
        $scriptBlock = (Get-Command Get-AzDevOpsProject).Parameters['ProjectName'].Attributes[1].ValidateScript
        $result = & $scriptBlock.Services $ProjectName
        $result | Should -Be $true
    }

    It 'Should return the project from cache when both ProjectId and ProjectName are provided' {
        $result = Get-AzDevOpsProject -ApiUri $ApiUri -Pat $Pat -ProjectId $ProjectId -ProjectName $ProjectName
        $result | Should -Not -BeNullOrEmpty
        $result.ProjectId | Should -Be $ProjectId
        $result.ProjectName | Should -Be $ProjectName
    }
}

