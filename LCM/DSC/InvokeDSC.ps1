
$ht = @{
    GroupName = "TestGroup"
    GroupDisplayName = "Test Group"
    GroupDescription = "I am a test group."
}

Invoke-DscResource -Name 'xAzDoOrganizationGroup' -Method Get -Property $ht -Verbose -ModuleName 'AzureDevOpsDsc'
