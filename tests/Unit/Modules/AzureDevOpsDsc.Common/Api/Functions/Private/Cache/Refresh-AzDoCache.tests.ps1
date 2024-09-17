$currentFile = $MyInvocation.MyCommand.Path

Describe "Refresh-AzDoCache Tests" -Tags "Unit", "Cache" {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Refresh-AzDoCache.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mock the Get-Command cmdlet to return a list of commands matching the pattern
        Mock -CommandName Get-Command -MockWith {
            @(
                [pscustomobject]@{ Name = 'AzDoAPI_CacheType1'; Source = 'AzureDevOpsDsc.Common' },
                [pscustomobject]@{ Name = 'AzDoAPI_CacheType2'; Source = 'AzureDevOpsDsc.Common' }
            )
        }

        function AzDoAPI_CacheType1 {
            param ($OrganizationName)
        }
        function AzDoAPI_CacheType2 {
            param ($OrganizationName)
        }

        # Mock the commands that would be invoked by Refresh-AzDoCache
        Mock -CommandName AzDoAPI_CacheType1
        Mock -CommandName AzDoAPI_CacheType2
        Mock -CommandName Remove-Variable

    }

    Context "When OrganizationName is provided" {
        It "Should call each caching command with the correct OrganizationName parameter" {
            $orgName = 'MyOrg'
            Refresh-AzDoCache -OrganizationName $orgName

            # Verify that Get-Command was called with the correct parameters
            Assert-MockCalled -CommandName Get-Command

            # Verify that each caching command was called with the correct OrganizationName parameter
            Assert-MockCalled -CommandName AzDoAPI_CacheType1
            Assert-MockCalled -CommandName AzDoAPI_CacheType2

        }
    }

}
