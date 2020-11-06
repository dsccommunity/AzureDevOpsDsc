Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1') -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestCases.psm1') -Force


if (-not (Test-BuildCategory -Type 'Unit'))
{
    return
}


$script:dscModuleName = 'AzureDevOpsDsc'
Remove-Module -Name $script:dscModuleName -Force -ErrorAction 'SilentlyContinue'
$script:dscModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
Import-Module -Name $script:dscModuleName -Force -ErrorAction 'Stop'
