
#. 'C:\Temp\AzureDevOpsDSC\LCM\Invoke-AZDOLCM.ps1'

#Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1'

$ht = @{
    GroupName = "TestGroup"
    GroupDisplayName = "Test Group"
    GroupDescription = "I am a test group."
}

#$VerbosePreference = "Continue"

Wait-Debugger
Invoke-DscResource -Name 'xAzDoOrganizationGroup' -Method Get -Property $ht -Verbose -ModuleName 'AzureDevOpsDsc' -Debug
