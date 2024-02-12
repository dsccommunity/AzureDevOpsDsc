#using module AzureDevOpsDsc
# Setup/Import 'DscResource.Common' helper module
#$script:resourceHelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
#Import-Module -Name $script:resourceHelperModulePath


$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


# Obtain all functions within PSModule
$functionSubDirectoryPaths = @(

    # Classes
    "$PSScriptRoot\Api\Classes\",

    # Enum
    "$PSScriptRoot\Api\Enums\",

    # Data
    "$PSScriptRoot\Api\Data\",

    # Api
    "$PSScriptRoot\Api\Functions\Private\Api",
    "$PSScriptRoot\Api\Functions\Private\Cache",
    "$PSScriptRoot\Api\Functions\Private\Helper",
    "$PSScriptRoot\Api\Functions\Private\ManagedIdentity",

    # Connection
    "$PSScriptRoot\Connection\Functions\Private",

    # Resources
    "$PSScriptRoot\Resources\Functions\Public",
    "$PSScriptRoot\Resources\Functions\Private",

    # Server

    # Services
    "$PSScriptRoot\Services\Functions\Public"
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

#
# Module initialization

<#
# Initialize cache
Initialize-CacheObject -CacheType 'LiveGroups'
Initialize-CacheObject -CacheType 'LiveProjects'

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName

#>
#
