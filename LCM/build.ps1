Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\Datum\powershell-yaml\0.4.7\powershell-yaml.psd1'
Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\Datum\datum\0.40.1\datum.psd1'

Set-Location 'C:\Temp\AzureDevOpsDSC\Example Configuration'

$Project = 'TestProject'
$Datum = New-DatumStructure -DefinitionFile Datum.yml

$AllNodes = $Datum.AllNodes.($Project).NodeGroups | ForEach-Object {
    $_
}

$ConfigurationData = @{
    AllNodes = $AllNodes
    Datum    = $Datum
}

$Node = $ConfigurationData.AllNodes

$a = (Lookup MergeTest1)

$TestProject = $Datum.AllNodes.TestProject.NodeGroups
Lookup 'project' -Node $TestProject -DatumTree $Datum
Lookup 'Resources' -Node $TestProject -DatumTree $Datum

Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Resources'

$r = Get-DatumRsop -Datum $Datum -AllNodes $Node -Verbose
