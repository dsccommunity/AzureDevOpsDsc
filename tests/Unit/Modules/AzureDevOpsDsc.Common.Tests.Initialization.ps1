#region HEADER
$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch{$false}) }
    ).BaseName

#Write-Warning "ProjectPath : $ProjectPath"
#Write-Warning "ProjectName : $ProjectName"


$script:ParentModule = Get-Module $ProjectName -ListAvailable | Select-Object -First 1
#Write-Warning "ParentModule : $script:ParentModule"
$script:SubModulesFolder = Join-Path -Path $script:ParentModule.ModuleBase -ChildPath 'Modules'
#Write-Warning "SubModulesFolder : $script:SubModulesFolder"

Remove-Module $script:ParentModule -Force -ErrorAction SilentlyContinue



$script:SubModuleName = (Split-Path $PSCommandPath -Leaf) -replace '\.Tests.ps1' -replace '\.Tests.Initialization.ps1'
#Write-Warning "SubModuleName : $script:SubModuleName"
Remove-Module $script:SubModuleName -force -ErrorAction SilentlyContinue
$script:SubmoduleFile = Join-Path $script:SubModulesFolder "$($script:SubModuleName)/$($script:SubModuleName).psm1"
#Write-Warning "SubmoduleFile : $script:SubmoduleFile"


#endregion HEADER

Import-Module $script:SubmoduleFile -Force -ErrorAction Stop


# Import helper modules containing helper functions and test values/cases
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelpers\CommonTestHelper.psm1') -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'TestHelpers\CommonTestCases.psm1') -Force
