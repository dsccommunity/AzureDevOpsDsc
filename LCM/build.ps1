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
$Baseline = $ConfigurationData.Datum.Baseline

#$a = (Lookup MergeTest1)

#$TestProject = $Datum.AllNodes.TestProject.NodeGroups
#Lookup 'project' -Node $TestProject -DatumTree $Datum
#Lookup 'Resources' -Node $Node -DatumTree $Datum

$Resources = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Resources'
$Variables = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Resources'
$Parameters = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Resources'
$Conditions = Resolve-Datum -SearchPaths $datum.__Definition.ResolutionPrecedence -DatumStructure $Datum -PropertyPath 'Resources'


