

Describe "xAzDoGitPermission Integration Tests" {

    BeforeAll {

    }


    Context "When running xAzDoGitPermission" {
        It "Should not throw any exceptions" {
            $null = Invoke-Pester -Script @{ Path = "$PSScriptRoot\Resources\xAzDoGitPermission.tests.ps1" } -PassThru
        }
    }
}
