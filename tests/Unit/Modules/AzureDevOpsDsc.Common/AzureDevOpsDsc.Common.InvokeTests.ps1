<#
    .SYNOPSIS
        Automated unit test for classes in AzureDevOpsDsc.
#>


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

$Global:RepositoryRoot = Split-RecurivePath $PSScriptRoot -Times 4
$script:CurrentFolder = Split-RecurivePath $PSScriptRoot -Times 1

Import-Module -Name (Join-Path -Path $script:RepositoryRoot -ChildPath '/tests/Unit/Modules/TestHelpers/CommonTestCases.psm1')
Import-Module -Name (Join-Path -Path $script:RepositoryRoot -ChildPath '/tests/Unit/Modules/TestHelpers/CommonTestHelper.psm1')
Import-Module -Name (Join-Path -Path $script:RepositoryRoot -ChildPath '/tests/Unit/Modules/TestHelpers/CommonTestFunctions.psm1')

#
# Recurse through the folders and invoke the tests.

$script:TestFolders = Get-ChildItem -Path (Join-Path -Path $script:CurrentFolder -ChildPath '\AzureDevOpsDsc.Common') -Directory

ForEach ($TestFolder in $script:TestFolders) {
    Invoke-Pester -Path $TestFolder.FullName -Output Detailed -PassThru
}
