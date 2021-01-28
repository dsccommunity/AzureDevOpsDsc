

# Import nested, 'AzureDevOpsDsc.Common' module
$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath


# Define localization data
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
