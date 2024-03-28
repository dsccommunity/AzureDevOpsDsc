

$params = Import-Clixml -LiteralPath "C:\Temp\newgroup.clixml"

Wait-Debugger
Set-xAzDoOrganizationGroup @params
