#Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

#if (-not (Test-BuildCategory -Type 'Integration'))
#{
#    return
#}

$script:dscModuleName = 'AzureDevOpsDsc'
$script:dscResourceFriendlyName = 'DSC_AzDevOpsProject'
$script:dscResourceName = $script:dscResourceFriendlyName

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
    -TestType 'Integration'


try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile


    Describe "$($script:dscResourceName)_Integration" {

        BeforeAll {
            $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
            . $configFile
        }


        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureGitProjectPresent_Config'") {


            Context ("When compiling, applying and testing the MOF") {

                BeforeAll {
                    $configurationName = "$($script:dscResourceName)_EnsureGitProjectPresent_Config"
                    $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureGitProjectPresent"
                }

                It 'Should not throw when compiling MOF and when calling "Start-DscConfiguration"' {
                    {
                        $configurationParameters = @{
                            OutputPath           = $TestDrive
                            # The variable $ConfigurationData was dot-sourced above.
                            ConfigurationData    = $ConfigurationData
                        }

                        . $configFile
                        & $configurationName @configurationParameters

                        $startDscConfigurationParameters = @{
                            Path         = $TestDrive
                            ComputerName = 'localhost'
                            Wait         = $true
                            Verbose      = $true
                            Force        = $true
                            ErrorAction  = 'Stop'
                        }

                        Start-DscConfiguration @startDscConfigurationParameters
                    } | Should -Not -Throw
                }


                It 'Should not throw when calling "Get-DscConfiguration"' {
                    {
                        $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                    } | Should -Not -Throw
                }


                It 'Should have set the resource and all the parameters should match' {
                    $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                        $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                    }

                    $resourceCurrentState.ProjectName | Should -Be 'TestGitProjectName'
                    $resourceCurrentState.ProjectDescription | Should -Be 'TestGitProjectDescription'
                    $resourceCurrentState.SourceControlType | Should -Be 'Git'
                }


                It 'Should return $true when Test-DscConfiguration is run' {
                    Test-DscConfiguration -Verbose | Should -Be 'True'
                }
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureTfvcProjectPresent_Config'") {


            Context ("When compiling, applying and testing the MOF") {

                BeforeAll {
                    $configurationName = "$($script:dscResourceName)_EnsureTfvcProjectPresent_Config"
                    $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureTfvcProjectPresent"
                }

                It 'Should not throw when compiling MOF and when calling "Start-DscConfiguration"' {
                    {
                        $configurationParameters = @{
                            OutputPath           = $TestDrive
                            # The variable $ConfigurationData was dot-sourced above.
                            ConfigurationData    = $ConfigurationData
                        }

                        . $configFile
                        & $configurationName @configurationParameters

                        $startDscConfigurationParameters = @{
                            Path         = $TestDrive
                            ComputerName = 'localhost'
                            Wait         = $true
                            Verbose      = $true
                            Force        = $true
                            ErrorAction  = 'Stop'
                        }

                        Start-DscConfiguration @startDscConfigurationParameters
                    } | Should -Not -Throw
                }


                It 'Should not throw when calling "Get-DscConfiguration"' {
                    {
                        $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                    } | Should -Not -Throw
                }


                It 'Should have set the resource and all the parameters should match' {
                    $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                        $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                    }

                    $resourceCurrentState.ProjectName | Should -Be 'TestTfvcProjectName'
                    $resourceCurrentState.ProjectDescription | Should -Be 'TestTfvcProjectDescription'
                    $resourceCurrentState.SourceControlType | Should -Be 'Tfvc'
                }


                It 'Should return $true when Test-DscConfiguration is run' {
                    Test-DscConfiguration -Verbose | Should -Be 'True'
                }
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureProjectPresent_Config'") {


            Context ("When compiling, applying and testing the MOF") {

                BeforeAll {
                    $configurationName = "$($script:dscResourceName)_EnsureProjectPresent_Config"
                    $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectPresent"
                }

                It 'Should not throw when compiling MOF and when calling "Start-DscConfiguration"' {
                    {
                        $configurationParameters = @{
                            OutputPath           = $TestDrive
                            # The variable $ConfigurationData was dot-sourced above.
                            ConfigurationData    = $ConfigurationData
                        }

                        . $configFile
                        & $configurationName @configurationParameters

                        $startDscConfigurationParameters = @{
                            Path         = $TestDrive
                            ComputerName = 'localhost'
                            Wait         = $true
                            Verbose      = $true
                            Force        = $true
                            ErrorAction  = 'Stop'
                        }

                        Start-DscConfiguration @startDscConfigurationParameters
                    } | Should -Not -Throw
                }


                It 'Should not throw when calling "Get-DscConfiguration"' {
                    {
                        $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                    } | Should -Not -Throw
                }


                It 'Should have set the resource and all the parameters should match' {
                    $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                        $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                    }

                    # These are all defaults from values provided in configuration data
                    $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
                    $resourceCurrentState.ProjectDescription | Should -Be 'TestProjectDescription'
                    $resourceCurrentState.SourceControlType | Should -Be 'Git'
                }


                It 'Should return $true when Test-DscConfiguration is run' {
                    Test-DscConfiguration -Verbose | Should -Be 'True'
                }
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureProjectUpdated_Config'") {

            Context ("When compiling, applying and testing the MOF") {

                BeforeAll {
                    $configurationName = "$($script:dscResourceName)_EnsureProjectUpdated_Config"
                    $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectUpdated"
                }


                It 'Should not throw when compiling MOF and when calling "Start-DscConfiguration"' {
                    {
                        $configurationParameters = @{
                            OutputPath           = $TestDrive
                            # The variable $ConfigurationData was dot-sourced above.
                            ConfigurationData    = $ConfigurationData
                        }

                        . $configFile
                        & $configurationName @configurationParameters

                        $startDscConfigurationParameters = @{
                            Path         = $TestDrive
                            ComputerName = 'localhost'
                            Wait         = $true
                            Verbose      = $true
                            Force        = $true
                            ErrorAction  = 'Stop'
                        }

                        Start-DscConfiguration @startDscConfigurationParameters
                    } | Should -Not -Throw
                }


                It 'Should not throw when calling "Get-DscConfiguration"' {
                    {
                        $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                    } | Should -Not -Throw
                }


                It 'Should have set the resource and all the parameters should match' {
                    $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                        $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                    }

                    $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
                    $resourceCurrentState.ProjectDescription | Should -Be 'AnAmendedProjectDescription'
                    $resourceCurrentState.SourceControlType | Should -Be 'Git' # Must be the same (change not supported with this)
                }


                It 'Should return $true when Test-DscConfiguration is run' {
                    Test-DscConfiguration -Verbose | Should -Be 'True'
                }
            }
        }

    }

}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
