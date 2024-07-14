
# Import Pester module for testing
Import-Module Pester

# Mock Test-AzDevOpsPat function
function Test-AzDevOpsPat {
    param ([string]$Pat, [bool]$IsValid)
    return $IsValid
}

Describe 'Get-AzDevOpsApiHttpRequestHeader Tests' {

    BeforeAll {
        # Define the function to be tested
        function Get-AzDevOpsApiHttpRequestHeader {
            [CmdletBinding()]
            [OutputType([Hashtable])]
            param (
                [Parameter(Mandatory = $true)]
                [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
                [Alias('PersonalAccessToken')]
                [System.String]
                $Pat
            )

            [Hashtable]$apiHttpRequestHeader = @{
                Authorization = 'Basic ' +
                    [Convert]::ToBase64String(
                        [Text.Encoding]::ASCII.GetBytes(":$Pat"))
            }

            return $apiHttpRequestHeader
        }
    }

    It 'Should return a Hashtable with valid Authorization header when a valid PAT is provided' {
        Mock -CommandName Test-AzDevOpsPat -MockWith { return $true }

        $Pat = 'validPat123'
        $expectedAuthHeader = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))

        $result = Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

        $result | Should -BeOfType 'hashtable'
        $result['Authorization'] | Should -Be "$expectedAuthHeader"
    }

    It 'Should throw an error when an invalid PAT is provided' {
        Mock -CommandName Test-AzDevOpsPat -MockWith { return $false }

        { Get-AzDevOpsApiHttpRequestHeader -Pat 'invalidPat123' } | Should -Throw 'Cannot validate argument on parameter'
    }

    It 'Should call Test-AzDevOpsPat with correct parameters' {
        Mock -CommandName Test-AzDevOpsPat -MockWith { return $true }

        $Pat = 'validPat456'
        Get-AzDevOpsApiHttpRequestHeader -Pat $Pat

        Assert-MockCalled -CommandName Test-AzDevOpsPat -Exactly -Times 1 -Parameters @{ Pat = $Pat; IsValid = $true }
    }
}

