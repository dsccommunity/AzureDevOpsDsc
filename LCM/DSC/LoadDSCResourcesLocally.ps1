Get-ChildItem -LiteralPath 'C:\Temp\AzureDevOpsDSC\source\Enum' -File | ForEach-Object {
    . $_.FullName
}
Get-ChildItem -LiteralPath 'C:\Temp\AzureDevOpsDSC\source\Classes' -File | ForEach-Object {
    # Read the file and remove [DscResource()] attribute
    $file = Get-Command $_.FullName
    # Remove [DscResource()] attribute
    $content = $file.ScriptContents -replace '\[DscResource\(\)\]', ''
    # Conver the string array into ScriptBlock
    $scriptBlock = [ScriptBlock]::Create($content)
    # Dot source the script block
    . $scriptBlock

}

