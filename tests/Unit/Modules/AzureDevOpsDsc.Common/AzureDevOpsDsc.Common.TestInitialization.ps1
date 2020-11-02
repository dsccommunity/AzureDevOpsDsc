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
$script:subModuleName = 'AzureDevOpsDsc.Common'

#region HEADER
Remove-Module -Name $script:subModuleName -Force -ErrorAction 'SilentlyContinue'

$script:parentModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'

$script:subModulePath = Join-Path -Path $script:subModulesFolder -ChildPath $script:subModuleName

Import-Module -Name $script:subModulePath -Force -ErrorAction 'Stop'
#endregion HEADER

# Loading mocked classes
#Add-Type -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs') -ChildPath 'SomeExampleMockedClass.cs')
