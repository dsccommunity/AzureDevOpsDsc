# # Initialize tests for module function
# . $PSScriptRoot\..\Classes.TestInitialization.ps1

# InModuleScope 'AzureDevOpsDsc' {

#     $script:dscModuleName = 'AzureDevOpsDsc'
#     $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
#     $script:subModuleName = 'AzureDevOpsDsc.Common'
#     $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
#     $script:dscResourceName = Split-Path $PSScriptRoot -Leaf
#     $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
#     $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\" -ChildPath "output\$($script:dscModuleName)\$($script:moduleVersion)\Classes\$script:dscResourceName\$script:dscResourceName.psm1"
#     $script:tag = @($($script:commandName -replace '-'))


#     Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {

#         #Import-Module $script:subModuleBase -Force
#         #Import-Module  $script:commandScriptPath -Force

#         Context 'When called from instance of the class' {

#             Mock Get-AzDevOpsDscProject {}

#             It 'Should not throw' {

#                 $azDevOpsDscResourceBase = [AzDevOpsDscResourceBase]::new()
#                 #[ScriptBlock]$GetResourceFunctionName = {return '{New-Object -TypeName PSObject -Property @{Egg="Face"}}'}
#                 #[ScriptBlock]$GetResourceFunctionName = {return 'New-Object -TypeName PSObject -Property'}
#                 #[ScriptBlock]$GetResourceFunctionName = {return 'Get-Module'}
#                 [ScriptBlock]$GetResourceFunctionName = {return 'Get-AzDevOpsDscProject'}
#                 $azDevOpsDscResourceBase | Add-Member -MemberType ScriptMethod -Name "GetResourceFunctionName" -Value $GetResourceFunctionName -Force

#                 $azDevOpsDscResourceBase.GetDscCurrentStateObject() | Should -Not -Throw
#             }
#         }
#     }
# }
