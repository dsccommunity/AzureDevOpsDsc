function ConvertTo-Base64String
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]
        $InputObject
    )

    process {
        [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($InputObject))
    }
}
