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

$r = Get-DatumRsop -Datum $Datum -AllNodes $Node -Verbose
