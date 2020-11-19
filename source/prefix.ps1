# '.psm1' Prefix

$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

