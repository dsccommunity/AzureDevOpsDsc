<#
.SYNOPSIS
    Performs a bitwise OR operation on an array of integers.

.DESCRIPTION
    The Get-BitwiseOrResult function takes an array of integers as input and performs a bitwise OR operation on them. It returns the result of the operation.

.PARAMETER integers
    Specifies the array of integers on which the bitwise OR operation is performed.

    Required?    true
    Position?    1
    Default value
    Accept pipeline input?    false
    Accept wildcard characters?    false

.EXAMPLE
    $inputArray = 1, 2, 4, 8
    $result = Get-BitwiseOrResult -integers $inputArray
    $result
    # Output: 15

.NOTES
    Author: Your Name
    Date:   Current Date
#>
Function Get-BitwiseOrResult
{
    [CmdletBinding()]
    param (
        [int[]]$integers
    )

    Write-Verbose "[Get-BitwiseOrResult] Started."
    Write-Verbose "[Get-BitwiseOrResult] Integers: $integers"

    $result = 0

    if ($integers.Count -eq 0)
    {
        return 0
    }

    foreach ($integer in $integers)
    {
        if (-not [int]::TryParse($integer.ToString(), [ref]$null))
        {
            Write-Error "Invalid integer value: $integer"
            return 0
        }
        $result = $result -bor $integer
    }

    if ([String]::IsNullOrEmpty($result))
    {
        return 0
    }

    return $result
}
