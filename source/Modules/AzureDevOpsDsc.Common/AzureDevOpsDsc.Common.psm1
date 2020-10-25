
# Obtain all functions within PSModule
$functionSubDirectoryPaths = @(
    "$PSScriptRoot\Functions\Public"
    "$PSScriptRoot\Functions\Private"
)
$functions = Get-ChildItem -Path $functionSubDirectoryPaths -Recurse -Include "*.ps1"


# Loop through all PSModule functions and import/dot-source them (and export them if 'Public')
ForEach ($function in $functions)
{
    Write-Verbose "Dot-sourcing '$($function.FullName)'..."
    . (
        [ScriptBlock]::Create(
            [Io.File]::ReadAllText($($function.FullName))
        )
    )

    If ($function.FullName -ilike "$PSScriptRoot\Functions\Public\*")
    {
        Write-Verbose "Exporting '$($function.BaseName)'..."
        Export-ModuleMember -Function $($function.BaseName)
    }
}
