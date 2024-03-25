using module "C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1"

$ErrorActionPreference = 'Break'
Write-Host -Message ([xAzDoOrganizationGroup]::new | out-string)
Wait-Debugger
$a = [xAzDoOrganizationGroup]::new()
