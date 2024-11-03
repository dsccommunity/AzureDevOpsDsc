$currentFile = $MyInvocation.MyCommand.Path

Describe 'Test-AzDevOpsApiHttpRequestHeader' {


    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDevOpsApiHttpRequestHeader.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }


    It 'Returns $true when HttpRequestHeader contains Metadata' {
        $header = @{ Metadata = 'someValue' }
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $true
    }

    It 'Returns $true when HttpRequestHeader.Authorization is a valid Basic auth' {
        $header = @{ Authorization = 'Basic: dXNlcm5hbWU6cGFzc3dvcmQ=' }
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $true
    }

    It 'Returns $true when HttpRequestHeader.Authorization is a valid Bearer token' {
        $header = @{ Authorization = 'Bearer: yourTokenHere' }
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $true
    }

    It 'Returns $true when HttpRequestHeader.Authorization is a valid Bearer token with space and no colon' {
        $header = @{ Authorization = 'Bearer yourTokenHere' }
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $true
    }

    It 'Returns $false when HttpRequestHeader.Authorization is null' {
        $header = @{ Authorization = $null }
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $false
    }

    It 'Returns $false when HttpRequestHeader is null' {
        $header = $null
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $false
    }

    It 'Returns $false when HttpRequestHeader.Authorization is invalid' {
        $header = @{ Authorization = 'InvalidAuthString' }
        $result = Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header -IsValid
        $result | Should -Be $false
    }

    It 'Throws exception when IsValid switch is missing' -skip {
        $header = @{ Authorization = 'Bearer: yourTokenHere' }
        { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $header } | Should -Throw
    }
}
