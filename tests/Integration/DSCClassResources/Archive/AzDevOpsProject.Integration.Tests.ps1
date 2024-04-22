Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '\..\..\Unit\Modules\TestHelpers\CommonTestHelper.psm1')

if (-not (Test-BuildCategory -Type 'Integration'))
{
    return
}

$script:dscModuleName = 'AzureDevOpsDsc'
$script:dscResourceFriendlyName = 'AzDevOpsProject'
$script:dscResourceName = $script:dscResourceFriendlyName

$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Source\Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath

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


        #   TODO: Add test for 'EnsureSourceControlTypeChangeInvalid'


        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureGitProjectAbsent1_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_EnsureGitProjectAbsent1_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureGitProjectAbsent1"
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

                $resourceCurrentState.Ensure | Should -Be 'Absent'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureGitProjectPresent_Config'") {

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

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ProjectName | Should -Be 'TestGitProjectName'
                $resourceCurrentState.ProjectDescription | Should -Be 'TestGitProjectDescription'
                $resourceCurrentState.SourceControlType | Should -Be 'Git'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_UpdateGitProjectToTfvc_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_UpdateGitProjectToTfvc_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_UpdateGitProjectToTfvc"
            }


            It 'Should throw when compiling MOF and when calling "Start-DscConfiguration"' {
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
                } | Should -Throw # Note: This operation is unsupported so we expect it to throw an exception
            }


            It 'Should not throw when calling "Get-DscConfiguration"' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

             It 'Should return $false or $null when Test-DscConfiguration is run' {
                  Test-DscConfiguration -Verbose -ErrorAction Stop  | Should -Be 'False'
             }
        }


        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureGitProjectAbsent2_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_EnsureGitProjectAbsent2_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureGitProjectAbsent2"
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

                $resourceCurrentState.Ensure | Should -Be 'Absent'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureTfvcProjectAbsent1_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_EnsureTfvcProjectAbsent1_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureTfvcProjectAbsent1"
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

                $resourceCurrentState.Ensure | Should -Be 'Absent'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureTfvcProjectPresent_Config'") {

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

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ProjectName | Should -Be 'TestTfvcProjectName'
                $resourceCurrentState.ProjectDescription | Should -Be 'TestTfvcProjectDescription'
                $resourceCurrentState.SourceControlType | Should -Be 'Tfvc'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_UpdateTfvcProjectToGit_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_UpdateTfvcProjectToGit_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_UpdateTfvcProjectToGit"
            }


            It 'Should throw when compiling MOF and when calling "Start-DscConfiguration"' {
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
                } | Should -Throw # Note: This operation is unsupported so we expect it to throw an exception
            }


            It 'Should not throw when calling "Get-DscConfiguration"' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should return $false or $null when Test-DscConfiguration is run' {
                 Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'False'
            }
        }


        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureTfvcProjectAbsent2_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_EnsureTfvcProjectAbsent2_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureTfvcProjectAbsent2"
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

                $resourceCurrentState.Ensure | Should -Be 'Absent'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureProjectPresent_Config'") {

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
                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
                $resourceCurrentState.ProjectDescription | Should -Be 'TestProjectDescription'
                $resourceCurrentState.SourceControlType | Should -Be 'Git'
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }

        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureProjectIdentical_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_EnsureProjectIdentical_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectIdentical"
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

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
                $resourceCurrentState.ProjectDescription | Should -Be 'TestProjectDescription'
                $resourceCurrentState.SourceControlType | Should -Be 'Git' # Must be the same (change not supported with this)
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }



        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureProjectUpdated_Config'") {

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

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
                $resourceCurrentState.ProjectDescription | Should -Be 'AnAmendedProjectDescription'
                $resourceCurrentState.SourceControlType | Should -Be 'Git' # Must be the same (change not supported with this)
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }


        Context ("When compiling, applying and testing the MOF - '$($script:dscResourceName)_EnsureProjectRemoved_Config'") {

            BeforeAll {
                $configurationName = "$($script:dscResourceName)_EnsureProjectRemoved_Config"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectRemoved"
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

                $resourceCurrentState.Ensure | Should -Be 'Absent'
                $resourceCurrentState.ProjectName | Should -BeNullOrEmpty
            }


            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose -ErrorAction Stop | Should -Be 'True'
            }
        }

    }

}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
