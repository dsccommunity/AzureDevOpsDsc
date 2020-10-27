<#
    .SYNOPSIS
        Automated unit test for DSC_AzDevOpsProject DSC resource.
#>

$script:dscModuleName = 'AzureDevOpsDsc'
$script:dscResourceName = 'DSC_AzDevOpsProject'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        Set-StrictMode -Version 1.0

        Describe 'AzDevOpsProject\Parameters' -Tag 'Parameter' {
            BeforeAll {
                #$mockInstanceName = 'DSCTEST'

                #Mock -CommandName Import-SQLPSModule
            }
        }

        Describe 'AzDevOpsProject\Get' -Tag 'Get' {

            $getProjectId = [GUID]::NewGuid()

            BeforeAll {

                $getProjectName = "ProjectName_$projectId"
                $getProjectDescription = "ProjectDescription_$projectId"

                $getParameters = @{
                    ProjectId = $getProjectId
                    ProjectName = $getProjectName
                    ProjectDescription = $getProjectDescription
                }

            }


            Context 'When Azure DevOps is not in the desired state' {
                Context 'When the Azure DevOps "Project" does not exist' {
                    BeforeAll {

                        $AzDevOpsProjectResource = [DSC_AzDevOpsProject]::new()
                        $AzDevOpsProjectResource = $AzDevOpsProjectResource |
                            Add-Member -MemberType 'ScriptMethod' -Name 'Get-AzDevOpsProject' -Value {
                                    return $null
                                } -Force -PassThru

                    }

                    It 'Should return the correct values' {
                        $getResult = $AzDevOpsProjectResource.Get()

                        $getResult | Should -Be $null
                        $getResult.ProjectId | Should -Be $null
                        $getResult.ProjectName | Should -Be $null
                        $getResult.ProjectDescription | Should -Be $null
                    }
                }


                Context 'When the Azure DevOps "Project" exists but "ProjectName" parameter is different' {
                    BeforeAll {
                        $differentProjectName = "z" + $getParameters.ProjectName
                        $getParameters.ProjectName = $differentProjectName

                        $AzDevOpsProjectResource = [DSC_AzDevOpsProject]::new()
                        $AzDevOpsProjectResource = $AzDevOpsProjectResource |
                            Add-Member -MemberType 'ScriptMethod' -Name 'Get-AzDevOpsProject' -Value {
                                    return $getParameters
                                } -Force -PassThru

                    }

                    #$differentProjectName = "z" + $getParameters.ProjectName
                    #$getParameters.ProjectName = $differentProjectName

                    #$AzDevOpsProjectResource = [DSC_AzDevOpsProject]::new()
                    #$AzDevOpsProjectResource = $AzDevOpsProjectResource |
                    #    Add-Member -MemberType 'ScriptMethod' -Name 'Get-AzDevOpsProject' -Value {
                    #            return $getParameters
                    #        } -Force -PassThru

                    #$AzDevOpsProjectResource = $AzDevOpsProjectResource |
                    #    Add-Member -NotePropertyName 'ApiUri' -NotePropertyValue 'https:\\someUri' -Force -PassThru

                    #$AzDevOpsProjectResource = $AzDevOpsProjectResource |
                    #    Add-Member -NotePropertyName 'Pat' -NotePropertyValue 'lxppuwlhjbxdteknmsbjfybsl6bdd5edsdisosv4hngd2rwou5pq' -Force -PassThru


                    It 'Should return the correct values' {
                        $getResult = $AzDevOpsProjectResource.Get()

                        $getResult.ProjectId | Should -Be $getProjectId
                        $getResult.ProjectName | Should -Be $differentProjectName
                        $getResult.ProjectDescription | Should -Be $getProjectDescription
                    }
                }

                Context 'When the Azure DevOps "Project" exists but "ProjectDescription" parameter is different' {
                    BeforeAll {
                        $differentProjectDescription = "z" + $getParameters.ProjectDescription
                        $getParameters.ProjectDescription = $differentProjectDescription

                        $AzDevOpsProjectResource = [DSC_AzDevOpsProject]::new()
                        $AzDevOpsProjectResource = $AzDevOpsProjectResource |
                            Add-Member -MemberType 'ScriptMethod' -Name 'Get-AzDevOpsProject' -Value {
                                    return $getParameters
                                } -Force -PassThru

                    }

                    It 'Should return the correct values' {
                        $getResult = $AzDevOpsProjectResource.Get()

                        #$getResult.ProjectId | Should -Be $getProjectId
                        $getResult.ProjectName | Should -Be $getprojectName
                        $getResult.ProjectDescription | Should -Be $differentProjectDescription
                    }
                }
            }

            Context 'When Azure DevOps is in the desired state' {
                BeforeAll {

                    $AzDevOpsProjectResource = [DSC_AzDevOpsProject]::new()
                    $AzDevOpsProjectResource = $AzDevOpsProjectResource |
                        Add-Member -MemberType 'ScriptMethod' -Name 'Get-AzDevOpsProject' -Value {
                                return $getParameters
                            } -Force -PassThru

                }

                It 'Should return the correct values' {
                    $getResult = [DSC_AzDevOpsProject]::Get()

                    #$getResult.ProjectId | Should -Be $getProjectId
                    $getResult.ProjectName | Should -Be $getprojectName
                    $getResult.ProjectDescription | Should -Be $getProjectDescription
                }

            }
        }

    }
}
finally
{
    Invoke-TestCleanup
}
