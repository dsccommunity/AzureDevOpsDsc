# ...

Context 'When input parameters are valid' {

    # ...

    Context 'When called with valid "Headers" parameter' {

        It 'Should not throw - "Headers"' {
            param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

            $headers = @{
                'Content-Type' = 'application/json'
                'Authorization' = 'Bearer token'
            }

            { Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $headers } | Should -Not -Throw
        }

        It 'Should invoke "Invoke-RestMethod" with the correct "Headers" parameter' {
            param ([System.String]$ApiUri, [System.String]$HttpMethod, [Hashtable]$HttpRequestHeader)

            $headers = @{
                'Content-Type' = 'application/json'
                'Authorization' = 'Bearer token'
            }

            Mock Invoke-RestMethod {
                param ([System.String]$Uri, [System.String]$Method, [Hashtable]$Headers)
                $Headers | Should -Be $headers
            } -Verifiable

            Invoke-AzDevOpsApiRestMethod -ApiUri $ApiUri -HttpMethod $HttpMethod -HttpRequestHeader $headers

            Assert-MockCalled Invoke-RestMethod -Times 1 -Exactly -Scope 'It'
        }
    }

    # ...
}
