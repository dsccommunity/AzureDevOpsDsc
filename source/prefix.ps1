

# Import nested, 'AzureDevOpsDsc.Common' module
$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath


# Define localization data
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


# Define 'enums' for module
enum Ensure
{
    Present
    Absent
}

enum RequiredAction
{
    None
    Get
    New
    Set
    Remove
    Test
    Error
}

