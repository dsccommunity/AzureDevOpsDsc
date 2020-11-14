<#
    .SYNOPSIS
        Automated unit test for classes in AzureDevOpsDsc.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '\..\Modules\TestHelpers\CommonTestHelper.psm1')
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '\..\Modules\TestHelpers\CommonTestCases.psm1')

$script:dscModuleName = 'AzureDevOpsDsc'
$script:dscModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
$script:dscModuleFile = $($script:dscModule.ModuleBase +'\'+ $script:dscModuleName + ".psd1")
Get-Module -Name $script:dscModuleName -All |
    Remove-Module $script:dscModuleName -Force -ErrorAction SilentlyContinue

$script:subModuleName = 'AzureDevOpsDsc.Common'
Import-Module -Name $script:dscModuleFile -Force

Get-Module -Name $script:subModuleName -All |
    Remove-Module -Force -ErrorAction SilentlyContinue
$script:subModulesFolder = Join-Path -Path $script:dscModule.ModuleBase -ChildPath 'Modules'
$script:subModuleFile = Join-Path $script:subModulesFolder "$($script:subModuleName)/$($script:subModuleName).psd1"
Import-Module -Name $script:subModuleFile -Force #-Verbose
