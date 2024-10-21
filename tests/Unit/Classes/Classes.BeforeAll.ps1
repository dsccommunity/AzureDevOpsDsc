param(
    [Parameter(Mandatory = $true)]
    [String]
    $RepositoryPath
)

$ClassesDirectory = "$RepositoryPath\source\Classes"
$EnumsDirectory = "$RepositoryPath\source\Enum"
$Global:ClassesLoaded = $true

#
# Load all the Enums

Get-ChildItem -LiteralPath $EnumsDirectory -File | ForEach-Object {
    Write-Verbose "Dot Sourcing $($_.FullName)"
    . $_.FullName
}

#
# Load all the Classes

Get-ChildItem -LiteralPath $ClassesDirectory -File | ForEach-Object {

    Write-Verbose "Dot Sourcing $($_.FullName)"
    # Read the file and remove [DscResource()] attribute
    $file = Get-Command $_.FullName
    # Remove [DscResource()] attribute
    $content = $file.ScriptContents -replace '\[DscResource\(\)\]', ''
    # Convert the string array into ScriptBlock
    $scriptBlock = [ScriptBlock]::Create($content)
    # Dot source the script block
    . $scriptBlock

}

#
# Load all the Helper Functions

Get-ChildItem -LiteralPath "$RepositoryPath\source\Modules\AzureDevOpsDsc.Common\Api\Functions\Private\Helper" -File -Recurse -Filter *.ps1 | ForEach-Object {
    Write-Verbose "Dot Sourcing $($_.FullName)"
    . $_.FullName
}
