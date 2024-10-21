$currentFile = $MyInvocation.MyCommand.Path

# Not used
Describe 'Test-AzDoProjectGroup' -skip {

    AfterAll {
        # Clean up
        Remove-Variable -Name DSCAZDO_OrganizationName -ErrorAction SilentlyContinue
    }

    BeforeAll {

        # Set the organization name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDoProjectGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')

        # Mocking external functions that are called within the function
        Mock -CommandName 'Get-CacheItem' -MockWith {
            param ($Key, $Type)
            if ($Key -eq "groupKey" -and $Type -eq 'LiveGroups') {
                return $true
            }
            return $false
        }
        Mock -CommandName 'Format-AzDoGroup' -MockWith { return "groupKey" }
    }

    Context 'When parameters are valid' {
        It 'Should return true when group is found in cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Unchanged
                Current = @{ description = 'Group Description' }
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return false when group name and description matches' {
            $GroupName = 'TestGroup'
            $GroupDescription = 'Group Description'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Unchanged
                Current = @{ description = $GroupDescription }
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -GetResult $GetResult
            $result | Should -BeFalse
        }

        It 'Should return true when status is Changed and group present in both live and cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Changed
                Current = @{}
                Cache = @{}
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return true when status is Changed and group present in live but not cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Changed
                Current = @{}
                Cache = $null
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return true when status is Changed and group not present in live but in cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Changed
                Current = $null
                Cache = @{}
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }

        It 'Should return false when status is Renamed' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Renamed
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeFalse
        }

        It 'Should return true when group present in cache' {
            $GroupName = 'TestGroup'
            $GetResult = @{
                Status = [DSCGetSummaryState]::Missing
            }

            $result = Test-AzDoProjectGroup -GroupName $GroupName -GetResult $GetResult
            $result | Should -BeTrue
        }
    }
}
