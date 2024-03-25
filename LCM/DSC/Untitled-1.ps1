Wait-Debugger
$a = [xAzDoOrganizationGroup]::New()
$a.GroupName = "Testgroup"
$a.GroupDisplayName = "Test Group"
$a.GroupDescription = "TEST Group"
$a.Get()
