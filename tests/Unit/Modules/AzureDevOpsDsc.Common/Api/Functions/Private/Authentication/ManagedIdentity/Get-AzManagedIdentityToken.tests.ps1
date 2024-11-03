$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-AzManagedIdentityToken Tests" -Tags "Unit", "Authentication" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzManagedIdentityToken.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
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


        Mock -CommandName Test-AzDevOpsApiHttpRequestHeader -MockWith {
            return $true
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith {
            return "6.0-preview.1"
        }

        Mock -CommandName New-ManagedIdentityToken -MockWith {
            return @{
                AccessToken = "fake-access-token"
                Expiry = (Get-Date).AddHours(1)
            }
        }

        Mock -CommandName Test-AzToken -MockWith { return $true }
        Mock -CommandName Get-OperatingSystemInfo -MockWith { return @{ Windows = $true; Linux = $false; MacOS = $false } }
        Mock -CommandName Get-Content -MockWith { return "mock-data" }
        Mock -CommandName Test-isWindowsAdmin -MockWith { return $true }

        class CustomException : Exception {
            [hashtable] $response

            CustomException($Message, $response) : base($Message) {
                $this.response = $response
            }
        }


        function Invoke-MockError {
            # Create a custom WebException with a response containing headers
            $response = @{
                Headers = @{
                    wwwAuthenticate = 'Basic realm=MOCKMOCKMOCKMOCKMOCKMOCK'
                }
            }

            throw [CustomException]::New("Mock Error", $response)
        }


    }

    Context "When Verify switch is not set" {

        BeforeAll {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return @{
                    access_token = "fake-access-token"
                }
            }
        }

        It "should return managed identity token" {
            $result = Get-AzManagedIdentityToken -OrganizationName "Contoso"
            $result.AccessToken | Should -Be "fake-access-token"
        }
    }

    Context "When it is an Azure Arc Machine and the console is not being run as Administrator" {

        AfterAll {
            Remove-Variable -Name IDENTITY_ENDPOINT -Scope Global -ErrorAction SilentlyContinue
        }

        BeforeAll {

            $env:IDENTITY_ENDPOINT = 'mock-url'

            Mock -CommandName Test-isWindowsAdmin -MockWith {
                return $false
            }
        }

        It "should throw error" {
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            } | Should -Throw "*Error: Authentication to Azure Arc requires Administrator privileges.*"
        }
    }

    Context "When it is an Azure Arc Machine and the console is being run as Administrator" {

        AfterAll {
            Remove-Variable -Name IDENTITY_ENDPOINT -Scope Global -ErrorAction SilentlyContinue
        }

        BeforeAll {

            $env:IDENTITY_ENDPOINT = 'mock-url'

            Mock -CommandName Test-isWindowsAdmin -MockWith {
                return $true
            }

        }

        It "should not throw error" {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $null -eq $HttpHeaders.Authorization
            } -MockWith { Invoke-MockError }

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $null -ne $HttpHeaders.Authorization
            } -MockWith { return @{ access_token = "mock-data" } }

            Get-AzManagedIdentityToken -OrganizationName "Contoso"
            Assert-MockCalled -CommandName Test-isWindowsAdmin
            Assert-MockCalled -CommandName Get-Content
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 2

        }
    }

    Context "Linux Machines" {

        BeforeAll {
            Mock -CommandName Test-isWindowsAdmin -MockWith {
                return $false
            }
            Mock -CommandName Get-OperatingSystemInfo -MockWith { return @{ Windows = $false; Linux = $true; MacOS = $false } }
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $null -eq $HttpHeaders.Authorization
            } -MockWith { Invoke-MockError }

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $null -ne $HttpHeaders.Authorization
            } -MockWith { return @{ access_token = "mock-data" } }
        }

        It "should not call Test-isWindowsAdmin" {
            Get-AzManagedIdentityToken -OrganizationName "Contoso"
            Assert-MockCalled -CommandName Test-isWindowsAdmin -Times 0
        }
    }

    Context "When Verify switch is set" {

        BeforeAll {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return @{
                    access_token = "fake-access-token"
                }
            }
        }

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

        BeforeAll {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                Throw "MOCK ERROR"
            }
        }

        It "should throw error" {
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            } | Should -Throw
        }
    }

}
