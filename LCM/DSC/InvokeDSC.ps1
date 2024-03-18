
$ht = @{
    GroupName = "TestGroup"
    GroupDisplayName = "Test Group"
    GroupDescription = "I am a test group."
}

Invoke-DscResource -Name 'AzDoOrganizationGroup' -Method Get -Property $ht -Verbose
