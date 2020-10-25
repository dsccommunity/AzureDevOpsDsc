
# Because these functions are not loaded prior to this
$SphenicPsModuleFunctions = "$PSScriptRoot\Functions"
Write-Verbose "$SphenicPsModuleFunctionsDirectory"
$functions = Get-ChildItem -Path "$SphenicPsModuleFunctions\Public\*", "$SphenicPsModuleFunctions\Private\*" -Include "*.ps1"

ForEach ($function in $functions) {

    Write-Verbose "Dot-sourcing '$($function.FullName)'..."
    . (
        [ScriptBlock]::Create(
            [Io.File]::ReadAllText($($function.FullName))
        )
	)

    If($function.FullName -ilike "$SphenicPsModuleFunctions\Public*"){
        Write-Verbose "Exporting '$($function.BaseName)'..."
        Export-ModuleMember -Function $($function.BaseName)
    }
}
