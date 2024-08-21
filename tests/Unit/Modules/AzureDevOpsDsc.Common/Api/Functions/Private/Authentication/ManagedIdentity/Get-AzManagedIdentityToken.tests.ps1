$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-AzManagedIdentityToken Tests" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzManagedIdentityToken.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Import the enums
        Import-Enums | ForEach-Object {
            . $_.FullName
        }

        # Import the classes
        . (Get-ClassFilePath '001.AuthenticationToken')
        . (Get-ClassFilePath '002.PersonalAccessToken')
        . (Get-ClassFilePath '003.ManagedIdentityToken')



        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{
                access_token = "fake-access-token"
            }
        }

        Mock -CommandName New-ManagedIdentityToken -MockWith {
            return @{
                AccessToken = "fake-access-token"
                Expiry = (Get-Date).AddHours(1)
            }
        }

        Mock -CommandName Test-AzToken -MockWith { return $true }

    }

    Context "When Verify switch is not set" {
        It "should return managed identity token" {
            Wait-Debugger
            $result = Get-AzManagedIdentityToken -OrganizationName "Contoso"
            $result.AccessToken | Should -Be "fake-access-token"
        }
    }

    Context "When Verify switch is set" {
        It "should return managed identity token after verification" {
            $result = Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
            $result.AccessToken | Should -Be "fake-access-token"
        }

        It "should throw error if Token verification fails" {
            Mock -CommandName Test-AzToken -MockWith {
                return $false
            } -ParameterFilter {
                $true
            }

            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
            } | Should -Throw "Error. Failed to call the Azure DevOps API."
        }
    }

    Context "When access token is not returned from Azure Instance Metadata Service" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{
                access_token = $null
            }
        } -ParameterFilter {
            $true
        }

        It "should throw error" {
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            } | Should -Throw "Error. Access token not returned from Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available."
        }
    }

    Context "When there is an error in Invoke-AzDevOpsApiRestMethod" {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            throw "Rest API Failure"
        } -ParameterFilter {
            $true
        }

        It "should throw captured error" {
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            } | Should -Throw "Rest API Failure"
        }
    }
}
