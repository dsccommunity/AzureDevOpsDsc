<#
    .SYNOPSIS
        Automated unit test for helper functions in module AzureDevOpsDsc.Common.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1') -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestCases.psm1') -Force

if (-not (Test-BuildCategory -Type 'Unit'))
{
    return
}

$script:dscModuleName = 'AzureDevOpsDsc'
$script:dscModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
$script:dscModuleFile = $($script:dscModule.ModuleBase +'\'+ $script:dscModuleName + ".psd1")
$script:subModuleName = 'AzureDevOpsDsc.Common'
Import-Module -Name $script:dscModuleFile -Force -Verbose

$script:subModulesFolder = Join-Path -Path $script:dscModule.ModuleBase -ChildPath 'Modules'
$script:subModuleFile = Join-Path $script:subModulesFolder "$($script:subModuleName)/$($script:subModuleName).psd1"
Import-Module -Name $script:subModuleFile -Force -Verbose
