Function Split-RecurivePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [int]$Times = 1
    )

    1 .. $Times | ForEach-Object {
        $Path = Split-Path -Path $Path -Parent
    }

    $Path
}

Function Invoke-BeforeEachFunctions {
    param(
        [string[]]$FileNames
    )

    # Locate the scriptroot for the module
    if ($Global:RepositoryRoot -eq $null) {
        $Global:RepositoryRoot = Split-RecurivePath $PSScriptRoot -Times 4
    }

    $ScriptRoot = $Global:RepositoryRoot

    if ($null -eq $Global:TestPaths) {
        $Global:TestPaths = Get-ChildItem -LiteralPath $ScriptRoot -Recurse -File -Include *.ps1 | Where-Object {
            ($_.FullName -notlike "*Tests.ps1") -and
            ($_.FullName -notlike '*\output\*') -and
            ($_.FullName -notlike '*\tests\*')
        }
    }

    # Perform a lookup for all BeforeEach FileNames
    $BeforeEachPath = @()
    ForEach ($FileName in $FileNames) {
        $BeforeEachPath += $Global:TestPaths | Where-Object { $_.Name -eq $FileName }
    }

    return $BeforeEachPath

}

Function Find-Functions {
    param(
        [String]$TestFilePath
    )

    $files = @()

    #
    # Using the File path of the test file, work out the function that is being tested
    $FunctionName = (Get-Item -LiteralPath $TestFilePath).BaseName -replace '\.tests$', ''
    $files += "$($FunctionName).ps1"


    #
    # Load the function into the AST and look for the mock commands.

    # Parse the PowerShell script file
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($TestFilePath, [ref]$null, [ref]$null)

    # Find all the Mock commands
    $MockCommands = $AST.FindAll({
        $args[0] -is [System.Management.Automation.Language.CommandAst] -and
        $args[0].CommandElements[0].Value -eq 'Mock'
    }, $true)

    # Iterate over the Mock commands and find the CommandName parameter
    foreach ($mockCommand in $MockCommands) {

        # Iterate over the CommandElements
        foreach ($element in $mockCommand.CommandElements) {

            # Check if the element is a CommandParameterAst and the parameter name is CommandName
            if ($element -is [System.Management.Automation.Language.CommandParameterAst] -and $element.ParameterName -eq 'CommandName') {
                $null = $element.Parent.Extent.Text -match '(-CommandName\s+(?<Function>[^\s]+))|(^Mock (?<Function>[^\s]+$))'
                $files += "$($matches.Function).ps1"
            }
        }
    }

    # Ignore the following list of functions
    $files = $files | Where-Object { $_ -notin @('Write-Error.ps1', 'Write-Output.ps1', 'Write-Verbose.ps1', 'Write-Warning.ps1') }
    # Return the unique list of functions
    $files = $files | Select-Object -Unique

    $files

}

Function Get-ClassFilePath {
    param(
        [string]$FileName
    )

    $Class = $Global:TestPaths | Where-Object { ($_.Name -eq $FileName) -or ($_.Name -eq "$FileName.ps1") }
    return $Class.FullName

}

Function Import-Enums {
    return ($Global:TestPaths | Where-Object { $_.Directory.Name -eq 'Enum' })
}

Export-ModuleMember -Function Split-RecurivePath, Invoke-BeforeEachFunctions, Find-Functions, Get-ClassFilePath, Import-Enums
