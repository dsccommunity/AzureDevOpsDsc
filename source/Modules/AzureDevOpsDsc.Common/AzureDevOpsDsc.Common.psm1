#using module AzureDevOpsDsc
# Setup/Import 'DscResource.Common' helper module
#$script:resourceHelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
#Import-Module -Name $script:resourceHelperModulePath


$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$ModuleRoot = $PSScriptRoot

# Obtain all functions within PSModule
$functionSubDirectoryPaths = @(

    # Classes
    "$ModuleRoot\Api\Classes\",

    # Enum
    "$ModuleRoot\Api\Enums\",

    # Data
    "$ModuleRoot\Api\Data\",

    # Api
    "$ModuleRoot\Api\Functions\Private\Api",
    "$ModuleRoot\Api\Functions\Private\Cache",
    "$ModuleRoot\Api\Functions\Private\Helper",
    "$ModuleRoot\Api\Functions\Private\ManagedIdentity",

    # Connection
    "$ModuleRoot\Connection\Functions\Private",

    # Resources
    "$ModuleRoot\Resources\Functions\Public",
    "$ModuleRoot\Resources\Functions\Private",

    # Server

    # Services
    "$ModuleRoot\Services\Functions\Public"
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

    if ($function.FullName -ilike "$ModuleRoot\*\Functions\Public\*")
    {
        Write-Verbose "Exporting '$($function.BaseName)'..."
        Export-ModuleMember -Function $($function.BaseName)
    }
}

#
# Module initialization

# Initialize cache
Initialize-CacheObject -CacheType 'LiveGroups'
Initialize-CacheObject -CacheType 'LiveProjects'

# Set the Organization Name
if ($Global:DSCAZDO_OrganizationName -eq $null) {
    throw "The global variable 'DSCAZDO_OrganizationName' is not set. Please set the variable to the name of the Azure DevOps organization."
}

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName

#
