
# Pester tests for Get-BitwiseOrResult function
Describe "Get-BitwiseOrResult" {
    BeforeAll {
        function Get-BitwiseOrResult {
            [CmdletBinding()]
            param (
                [int[]]$integers
            )

            Write-Verbose "[Get-BitwiseOrResult] Started."
            Write-Verbose "[Get-BitwiseOrResult] Integers: $integers"

            $result = 0

            if ($integers.Count -eq 0) {
                return 0
            }

            foreach ($integer in $integers) {
                if (-not [int]::TryParse($integer.ToString(), [ref]$null)) {
                    Write-Error "Invalid integer value: $integer"
                    return
                }
                $result = $result -bor $integer
            }

            return $result
        }
    }

    It "Should return 15 for input array 1, 2, 4, 8" {
        $inputArray = 1, 2, 4, 8
        $result = Get-BitwiseOrResult -integers $inputArray
        $result | Should -Be 15
    }

    It "Should return 0 for an empty array" {
        $inputArray = @()
        $result = Get-BitwiseOrResult -integers $inputArray
        $result | Should -Be 0
    }

    It "Should return correct result for single element array" {
        $inputArray = 3
        $result = Get-BitwiseOrResult -integers $inputArray
        $result | Should -Be 3
    }

    It "Should handle negative integers" {
        $inputArray = -1, -2, -4, -8
        $result = Get-BitwiseOrResult -integers $inputArray
        $result | Should -Be -1
    }

    It "Should return 0 when invalid integer is encountered" {
        $inputArray = 1, "two", 3
        $result = Get-BitwiseOrResult -integers $inputArray
        $result | Should -Be $null
    }
}

