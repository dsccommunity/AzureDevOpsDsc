# Initialize tests for module function
. $PSScriptRoot\..\DSCClassResources.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version
    $script:subModuleName = 'AzureDevOpsDsc.Common'
    $script:subModuleBase = $(Get-Module $script:subModuleName).ModuleBase
    $script:dscResourceName = Split-Path $PSScriptRoot -Leaf
    $script:commandName = $(Get-Item $PSCommandPath).BaseName.Replace('.Tests','')
    $script:commandScriptPath = Join-Path "$PSScriptRoot\..\..\..\..\" -ChildPath "output\builtModule\$($script:dscModuleName)\$($script:moduleVersion)\Classes\$script:dscResourceName\$script:dscResourceName.psm1"
    $script:tag = @($($script:commandName -replace '-'))


    Describe "$script:subModuleName\Classes\DscResourceBase\Method\$script:commandName" -Tag $script:tag {


        $azDevOpsProjectProperties = @{
            Ensure             = 'Present'
            ApiUri             = 'https://some.api.uri/_apis/'
            Pat                = '1234567890123456789012345678901234567890123456789012'
            ProjectId          = 'efb9c508-115d-4380-a038-51f970d7f918' # Random GUID
            ProjectName        = 'SomeProjectName'
            ProjectDescription = 'SomeProjectDescription'
            SourceControlType  = 'Git'
        }

        $azDevOpsProjectApiResource = [PSObject]@{
            id           = 'efb9c508-115d-4380-a038-51f970d7f918' # Random GUID
            name         = 'SomeProjectName'
            description  = 'SomeProjectDescription'
            capabilities = @{
                versioncontrol = @{
                    sourceControlType = 'Git'
                }
            }
        }

        $currentResourceObjectThatExists = [PSObject]$azDevOpsProjectApiResource
        $currentResourceObjectThatDoesNotExist = [PSObject]@{}


        $testCasesValidAzDevOpsProjectProperties = $azDevOpsProjectProperties.Keys | ForEach-Object {
            @{
                PropertyName = $_
            }
        }
        $testCasesValidAzDevOpsProjectPropertiesWhenNotExists = $testCasesValidAzDevOpsProjectProperties |
            Where-Object { $_.PropertyName -in @('Ensure', 'ApiUri', 'Pat') }


        Context 'When current resource already exists' {

            It 'Should not throw' {

                $azDevOpsProject = [AzDevOpsProject]::new()

                {$azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatExists)} | Should -Not -Throw
            }

            It 'Should return a hashtable with expected key/property - "<PropertyName>"' -TestCases $testCasesValidAzDevOpsProjectProperties {
                param ([System.String]$PropertyName)

                $azDevOpsProject = [AzDevOpsProject]::new()

                $azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatExists).ContainsKey($PropertyName) | Should -Be $true
            }

            It 'Should return a hashtable with an "Ensure" key value of "Present"' {

                $azDevOpsProject = [AzDevOpsProject]::new()

                $azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatExists).Ensure | Should -Be "Present"
            }

            It 'Should return a hashtable with output values matching corresponding, API resource values' {

                $azDevOpsProject = [AzDevOpsProject]@{
                    ProjectId = $azDevOpsProjectProperties.ProjectId
                }

                $dscCurrentStateProperties = $azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatExists)

                $dscCurrentStateProperties.ProjectId | Should -Be $azDevOpsProjectApiResource.id
                $dscCurrentStateProperties.ProjectName | Should -Be $azDevOpsProjectApiResource.name
                $dscCurrentStateProperties.ProjectDescription | Should -Be $azDevOpsProjectApiResource.description
                $dscCurrentStateProperties.SourceControlType | Should -Be $azDevOpsProjectApiResource.capabilities.versioncontrol.sourceControlType
            }

            It 'Should return a hashtable with output values matching corresponding, non-API resource values' {

                $azDevOpsProject = [AzDevOpsProject]@{
                    ApiUri = $azDevOpsProjectProperties.ApiUri
                    Pat = $azDevOpsProjectProperties.Pat
                }

                $dscCurrentStateProperties = $azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatExists)

                $dscCurrentStateProperties.ApiUri | Should -Be $azDevOpsProjectProperties.ApiUri
                $dscCurrentStateProperties.Pat | Should -Be $azDevOpsProjectProperties.Pat
            }
        }


        Context 'When current resource does not exist (not $null but with no "id" property)' {

            It 'Should not throw' {

                $azDevOpsProject = [AzDevOpsProject]::new()

                {$azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatDoesNotExist)} | Should -Not -Throw
            }

            It 'Should return a hashtable with expected key/property - "<PropertyName>"' -TestCases $testCasesValidAzDevOpsProjectPropertiesWhenNotExists {
                param ([System.String]$PropertyName)

                $azDevOpsProject = [AzDevOpsProject]::new()

                $azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatDoesNotExist).ContainsKey($PropertyName) | Should -Be $true
            }

            It 'Should return a hashtable with an "Ensure" key value of "Absent"' {

                $azDevOpsProject = [AzDevOpsProject]::new()

                $azDevOpsProject.GetDscCurrentStateProperties($currentResourceObjectThatDoesNotExist).Ensure | Should -Be "Absent"
            }
        }


        Context 'When current resource is null' {

            It 'Should not throw' {

                $azDevOpsProject = [AzDevOpsProject]::new()

                {$azDevOpsProject.GetDscCurrentStateProperties($null)} | Should -Not -Throw
            }

            It 'Should return a hashtable with expected key/property - "<PropertyName>"' -TestCases $testCasesValidAzDevOpsProjectPropertiesWhenNotExists {
                param ([System.String]$PropertyName)

                $azDevOpsProject = [AzDevOpsProject]::new()

                $azDevOpsProject.GetDscCurrentStateProperties($null).ContainsKey($PropertyName) | Should -Be $true
            }

            It 'Should return a hashtable with an "Ensure" key value of "Absent"' {

                $azDevOpsProject = [AzDevOpsProject]::new()

                $azDevOpsProject.GetDscCurrentStateProperties($null).Ensure | Should -Be "Absent"
            }
        }
    }
}








# <#
#     .SYNOPSIS
#         Automated unit test for AzDevOpsProject DSC Resource.
# #>

# $script:dscModuleName = 'AzureDevOpsDsc'
# $script:dscResourceName = 'AzDevOpsProject'

# function Invoke-TestSetup
# {
#     try
#     {
#         Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
#     }
#     catch [System.IO.FileNotFoundException]
#     {
#         throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
#     }

#     $script:testEnvironment = Initialize-TestEnvironment `
#         -DSCModuleName $script:dscModuleName `
#         -DSCResourceName $script:dscResourceName `
#         -ResourceType 'Class' `
#         -TestType 'Unit'
# }

# function Invoke-TestCleanup
# {
#     Restore-TestEnvironment -TestEnvironment $script:testEnvironment
# }

# # Begin Testing

# Invoke-TestSetup

# try
# {
#     InModuleScope $script:dscResourceName {
#         Set-StrictMode -Version 1.0

#         Describe 'AzDevOpsProject\Parameters' -Tag 'Parameter' {
#             BeforeAll {
#                 #$mockInstanceName = 'DSCTEST'

#                 #Mock -CommandName Import-SQLPSModule
#             }
#         }

#         Describe 'AzDevOpsProject\Get' -Tag 'Get' {



#             BeforeAll {

#                 $getApiUri = "https://www.someUri.api/_apis/"
#                 $getPat = "1234567890123456789012345678901234567890123456789012"

#                 $getProjectId = [GUID]::NewGuid().ToString()
#                 $getProjectName = "ProjectName_$projectId"
#                 $getProjectDescription = "ProjectDescription_$projectId"

#                 $getAzDevOpsResource = @{
#                     id = $getProjectId
#                     name = $getProjectName
#                     description = $getProjectDescription
#                 }

#                 $AzDevOpsProjectResource = [AzDevOpsProject]@{
#                     ApiUri = $getApiUri
#                     Pat = $getPat
#                     ProjectId = $getProjectId
#                     ProjectName = $getProjectName
#                     ProjectDescription = $getProjectDescription
#                 }
#             }


#             Context 'When Azure DevOps is not in the desired state' {
#                 Context 'When the Azure DevOps "Project" does not exist' {
#                     BeforeAll {

#                         $AzDevOpsProjectResource = $AzDevOpsProjectResource |
#                             Add-Member -MemberType 'ScriptMethod' -Name 'GetAzDevOpsResource' -Value {
#                                     return $null
#                                 } -Force -PassThru

#                     }

#                     It 'Should return the correct values' {
#                         $getResult = $AzDevOpsProjectResource.Get()

#                         $getResult | Should -Be $null
#                         $getResult.ApiUri | Should -Be $null
#                         $getResult.Pat | Should -Be $null
#                         $getResult.ProjectId | Should -Be $null
#                         $getResult.ProjectName | Should -Be $null
#                         $getResult.ProjectDescription | Should -Be $null
#                     }
#                 }


#                 Context 'When the Azure DevOps "Project" exists but "ProjectId" parameter is different' {
#                     BeforeAll {
#                         $differentProjectId = [GUID]::NewGuid().ToString()
#                         $getAzDevOpsResource.ProjectId = $differentProjectId

#                         $AzDevOpsProjectResource = $AzDevOpsProjectResource |
#                             Add-Member -MemberType 'ScriptMethod' -Name 'GetAzDevOpsResource' -Value {
#                                     return $getAzDevOpsResource
#                                 } -Force -PassThru

#                     }

#                     It 'Should return the correct values, with "ProjectId" values different' {
#                         $getResult = $AzDevOpsProjectResource.Get()

#                         $getResult.ApiUri | Should -Be $getApiUri
#                         $getResult.Pat | Should -Be $getPat
#                         $getResult.ProjectId | Should -Not -Be $differentProjectId # Different
#                         $getResult.ProjectName | Should -Be $getProjectName
#                         $getResult.ProjectDescription | Should -Be $getProjectDescription
#                     }
#                 }


#                 Context 'When the Azure DevOps "Project" exists but "ProjectName" parameter is different' {
#                     BeforeAll {
#                         $differentProjectName = "z" + $getAzDevOpsResource.ProjectName
#                         $getAzDevOpsResource.ProjectName = $differentProjectName

#                         $AzDevOpsProjectResource = $AzDevOpsProjectResource |
#                             Add-Member -MemberType 'ScriptMethod' -Name 'GetAzDevOpsResource' -Value {
#                                     return $getAzDevOpsResource
#                                 } -Force -PassThru

#                     }

#                     It 'Should return the correct values, with "ProjectName" values different' {
#                         $getResult = $AzDevOpsProjectResource.Get()

#                         $getResult.ApiUri | Should -Be $getApiUri
#                         $getResult.Pat | Should -Be $getPat
#                         $getResult.ProjectId | Should -Be $getProjectId
#                         $getResult.ProjectName | Should -Not -Be $differentProjectName # Different
#                         $getResult.ProjectDescription | Should -Be $getProjectDescription
#                     }
#                 }

#                 Context 'When the Azure DevOps "Project" exists but "ProjectDescription" parameter is different' {
#                     BeforeAll {
#                         $differentProjectDescription = "z" + $getAzDevOpsResource.ProjectDescription
#                         $getAzDevOpsResource.ProjectDescription = $differentProjectDescription

#                         $AzDevOpsProjectResource = $AzDevOpsProjectResource |
#                             Add-Member -MemberType 'ScriptMethod' -Name 'GetAzDevOpsResource' -Value {
#                                     return $getAzDevOpsResource
#                                 } -Force -PassThru

#                     }

#                     It 'Should return the correct values, with "ProjectDescription" values different' {
#                         $getResult = $AzDevOpsProjectResource.Get()

#                         $getResult.ApiUri | Should -Be $getApiUri
#                         $getResult.Pat | Should -Be $getPat
#                         $getResult.ProjectId | Should -Be $getProjectId
#                         $getResult.ProjectName | Should -Be $getprojectName
#                         $getResult.ProjectDescription | Should -Not -Be $differentProjectDescription # Different
#                     }
#                 }
#             }

#             Context 'When Azure DevOps is in the desired state' {
#                 BeforeAll {

#                     $AzDevOpsProjectResource = $AzDevOpsProjectResource |
#                         Add-Member -MemberType 'ScriptMethod' -Name 'GetAzDevOpsResource' -Value {
#                                 return $getAzDevOpsResource
#                             } -Force -PassThru

#                 }

#                 It 'Should return the correct values' {
#                     $getResult = $AzDevOpsProjectResource.Get()

#                     $getResult.ApiUri | Should -Be $getApiUri
#                     $getResult.Pat | Should -Be $getPat
#                     $getResult.ProjectId | Should -Be $getProjectId
#                     $getResult.ProjectName | Should -Be $getprojectName
#                     $getResult.ProjectDescription | Should -Be $getProjectDescription
#                 }

#             }
#         }

#     }
# }
# finally
# {
#     Invoke-TestCleanup
# }
