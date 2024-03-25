using module "C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1"


$a = [xAzDoOrganizationGroup]::New()
$a.GroupName = "Testgroup"
$a.GroupDisplayName = "Test Group"
$a.GroupDescription = "TEST Group"
$a.Get()
Wait-Debugger
$a.Test()
