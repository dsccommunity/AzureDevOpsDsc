<#
    .SYNOPSIS
        Automated unit test for classes in AzureDevOpsDsc.
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '\..\Modules\TestHelpers\CommonTestHelper.psm1')

if (-not (Test-BuildCategory -Type 'Unit'))
{
    return
}

$script:dscModuleName = 'AzureDevOpsDsc'
$script:dscModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
$script:dscModuleFile = $($script:dscModule.ModuleBase +'\'+ $script:dscModuleName + ".psd1")
$script:subModuleName = 'AzureDevOpsDsc.Common'
Import-Module -Name $script:dscModuleFile -Force -Verbose
