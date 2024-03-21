
. 'C:\Temp\AzureDevOpsDSC\LCM\Invoke-AZDOLCM.ps1'

#Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1'

$ht = @{
    GroupName = "Testgroup"
    GroupDisplayName = "Test Group"
    GroupDescription = "I am a test group."
}

#$VerbosePreference = "Continue"

#Wait-Debugger
$get = Invoke-DscResource -Name 'xAzDoOrganizationGroup' -Method Get -Property $ht -Verbose -ModuleName 'AzureDevOpsDsc' -Debug

$a = [xAzDoOrganizationGroup]::New()
$a.GroupName = "Testgroup"
$a.GroupDisplayName = "Test Group"
$a.GroupDescription = "TEST Group"
$a.Get()
