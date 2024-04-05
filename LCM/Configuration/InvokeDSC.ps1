
. 'C:\Temp\AzureDevOpsDSC\LCM\Invoke-AZDOLCM.ps1'

#Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1'
<#
$ht = @{
    GroupName = "Test Group AAAAAAAA123"
    #GroupDisplayName = "Test Group"
    GroupDescription = "I am a test group"
    Ensure = "Absent"
}
#>


## DSC RESOURCE

Configuration Test {
    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    xAzDoProjectGroup TestProjectGroup {
        GroupName = "Test Project Group"
        #GroupDisplayName = "Test Group"
        GroupDescription = "I am a test group"
        ProjectName = "AkkodisTest"
        Ensure = "Absent"
    }
}

$ht = @{
    Resource = 'xAzDoProjectGroup'
    Name = 'TestProjectGroup'
    Properties = @{
        GroupName = "Test Group AAAAAAAA123"
        #GroupDisplayName = "Test Group"
        GroupDescription = "I am a test group"
        Ensure = "Absent"
    }
}

$ht = @{
    GroupName = "Test Project Group"
    #GroupDisplayName = "Test Group"
    GroupDescription = "I am a test group"
    ProjectName = "AkkodisTest"
    Ensure = "Absent"
}

#$VerbosePreference = "Continue"

$ErrorActionPreference = "break"

#Wait-Debugger
#$get = Invoke-DscResource -Name 'xAzDoProjectGroup' -Method Get -Property $ht -ModuleName 'AzureDevOpsDsc' -Debug
#$test = Invoke-DscResource -Name 'xAzDoProjectGroup' -Method Test -Property $ht -ModuleName 'AzureDevOpsDsc' -Debug
#$set = Invoke-DscResource -Name 'xAzDoProjectGroup' -Method Set -Property $ht -ModuleName 'AzureDevOpsDsc' -Debug

#$test = Invoke-DscResource -Name 'xAzDoOrganizationGroup' -Method Test -Property $ht -ModuleName 'AzureDevOpsDsc' -Debug

<#
$a = [xAzDoOrganizationGroup]::New()
$a.GroupName = "Test Group AAA"
#$a.GroupDisplayName = "Test Group"
$a.GroupDescription = "TEST Group"
$a.Get()
#>
