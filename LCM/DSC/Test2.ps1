

$params = Import-Clixml -LiteralPath "C:\Temp\dscDesiredStateParameters.xml"

Wait-Debugger
Set-xAzDoOrganizationGroup @params
