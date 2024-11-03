$currentFile = $MyInvocation.MyCommand.Path

Describe "Add-AuthenticationHTTPHeader" -Tags "Unit", "Authentication" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-AuthenticationHTTPHeader.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Update-AzManagedIdentity

    }

    BeforeEach {
        # Reset the global variables before each test
        $Global:DSCAZDO_AuthenticationToken = $null
        $Global:DSCAZDO_OrganizationName = "TestOrg"
    }

    It "Throws an error when the token is null" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = $null
        }
        { Add-AuthenticationHTTPHeader } | Should -Throw '*The authentication token is null*'
    }

    It "Returns header for PersonalAccessToken" {
        $Global:DSCAZDO_AuthenticationToken = [PSCustomObject]@{
            tokenType = 'PersonalAccessToken'
        }
        $Global:DSCAZDO_AuthenticationToken | Add-Member -MemberType ScriptMethod -Name Get -Value { return "dummyPAT" }

        $result = Add-AuthenticationHTTPHeader
        $result | Should -Be "Authorization: Basic dummyPAT"
    }

    It "Returns header for ManagedIdentity when token is not expired" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'ManagedIdentity'
        }
        $Global:DSCAZDO_AuthenticationToken | Add-Member -MemberType ScriptMethod -Name Get -Value { return "dummyPAT" }
        $Global:DSCAZDO_AuthenticationToken | Add-Member -MemberType ScriptMethod -Name isExpired -Value { return $false }

        $result = Add-AuthenticationHTTPHeader
        $result | Should -Be "Bearer dummyPAT"
    }

    It "Updates and returns header for ManagedIdentity when token is expired" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'ManagedIdentity'
        }
        $Global:DSCAZDO_AuthenticationToken | Add-Member -MemberType ScriptMethod -Name Get -Value { return "dummyPAT" }
        $Global:DSCAZDO_AuthenticationToken | Add-Member -MemberType ScriptMethod -Name isExpired -Value { return $true }


        # Mock Update-AzManagedIdentity cmdlet
        Mock -CommandName Update-AzManagedIdentity -MockWith {
            $obj = [PSCustomObject]@{
                tokenType = 'ManagedIdentity'
            }
            $obj | Add-Member -MemberType ScriptMethod -Name Get -Value { return "newMIToken" }
            $obj | Add-Member -MemberType ScriptMethod -Name isExpired -Value { return $false }

            return $obj
        }

        $result = Add-AuthenticationHTTPHeader
        $result | Should -Be "Bearer newMIToken"
    }

    It "Throws an error for unsupported token type" {
        $Global:DSCAZDO_AuthenticationToken = @{
            tokenType = 'UnsupportedToken'
            Get = { return "dummyToken" }
        }
        { Add-AuthenticationHTTPHeader } | Should -Throw '*The authentication token type is not supported*'
    }

}
