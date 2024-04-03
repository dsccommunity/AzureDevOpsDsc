

$params = Import-Clixml -LiteralPath "C:\Temp\a.clixml"

Wait-Debugger
New-DevOpsGroup -GroupName $params.GroupName -GroupDescription $params.GroupDescription -ApiUri ("https://vssps.dev.azure.com/{0}" -f $Global:DSCAZDO_OrganizationName)

#Set-xAzDoOrganizationGroup @params
