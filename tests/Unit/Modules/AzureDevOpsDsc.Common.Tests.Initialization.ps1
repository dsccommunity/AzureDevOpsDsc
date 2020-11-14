# #region HEADER
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

$script:SubmoduleFile = Join-Path $($script:SubModulesFolder) -ChildPath "$($script:SubModuleName)\$($script:SubModuleName).psd1"
#Write-Warning "SubmoduleFile : $script:SubmoduleFile"

Remove-Module $script:SubModuleName -Force -ErrorAction SilentlyContinue


# #endregion HEADER

Import-Module $script:SubmoduleFile -Force -ErrorAction Stop
