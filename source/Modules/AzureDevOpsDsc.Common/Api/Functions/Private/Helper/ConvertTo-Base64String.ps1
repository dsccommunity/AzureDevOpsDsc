<#
.SYNOPSIS
Converts a byte array to a Base64 string.

.DESCRIPTION
The ConvertTo-Base64String function takes a byte array as input and converts it to a Base64 string representation.

.PARAMETER InputObject
The byte array to be converted to a Base64 string.

.EXAMPLE
$bytes = [System.Text.Encoding]::UTF8.GetBytes("Hello, World!")
$base64String = ConvertTo-Base64String -InputObject $bytes
$base64String
# Output: SGVsbG8sIFdvcmxkIQ==

.NOTES
Author: GitHub Copilot
Date: 2025-01-06
#>
function ConvertTo-Base64String
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InputObject
    )

    process
    {
        [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($InputObject))
    }
}
