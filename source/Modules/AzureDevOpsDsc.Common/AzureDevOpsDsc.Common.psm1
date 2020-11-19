# Setup/Import 'DscResource.Common' helper module
#$script:resourceHelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
#Import-Module -Name $script:resourceHelperModulePath


$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


# Obtain all functions within PSModule
$functionSubDirectoryPaths = @(

    # Api
    "$PSScriptRoot\Api\Functions\Public",
    "$PSScriptRoot\Api\Functions\Private",

    # Connection
    "$PSScriptRoot\Connection\Functions\Public",
    "$PSScriptRoot\Connection\Functions\Private",

    # Resources
    "$PSScriptRoot\Resources\Functions\Public",
    "$PSScriptRoot\Resources\Functions\Private",

    # Server
    "$PSScriptRoot\Server\Functions\Public",
    "$PSScriptRoot\Server\Functions\Private",

    # Services
    "$PSScriptRoot\Services\Functions\Public",
    "$PSScriptRoot\Services\Functions\Private"
)
$functions = Get-ChildItem -Path $functionSubDirectoryPaths -Recurse -Include "*.ps1"


# Loop through all PSModule functions and import/dot-source them (and export them if 'Public')
foreach ($function in $functions)
{
    Write-Verbose "Dot-sourcing '$($function.FullName)'..."
    . (
        [ScriptBlock]::Create(
            [Io.File]::ReadAllText($($function.FullName))
        )
    )

    if ($function.FullName -ilike "$PSScriptRoot\*\Functions\Public\*")
    {
        Write-Verbose "Exporting '$($function.BaseName)'..."
        Export-ModuleMember -Function $($function.BaseName)
    }
}
