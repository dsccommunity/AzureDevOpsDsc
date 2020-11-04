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


        # Assign these at the script level
        $script:configurationName = "$($script:dscResourceName)_EnsureProjectPresent_Config"
        $script:resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectPresent"


        Context ("When compiling, applying and testing the MOF - '$ConfigurationName'") {

            # Assign this within this context (from the script level)
            $configurationName = $script:configurationName
            $resourceId = $script:resourceId


            Context ("When compiling, applying and testing the MOF") {

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
                    $resourceCurrentState.ProjectDescription | Should -Be 'TestProjectDescription'
                }


                It 'Should return $true when Test-DscConfiguration is run' {
                    Test-DscConfiguration -Verbose | Should -Be 'True'
                }
            }
        }

    }



    # Describe "$($script:dscResourceName)_Integration" {

    #     BeforeAll {
    #         $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    #         . $configFile
    #     }



    #     $script:configurationName = "$($script:dscResourceName)_EnsureProjectPresent_Config"
    #     $script:resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectPresent"

    #     Context ('When using configuration {0}' -f $script:configurationName) {

    #         BeforeAll {
    #             $configurationName = "$($script:dscResourceName)_EnsureProjectPresent_Config"
    #             $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectPresent"
    #         }

    #         It 'Should compile and apply the MOF without throwing' {
    #             {
    #                 $configurationParameters = @{
    #                     OutputPath           = $TestDrive
    #                     # The variable $ConfigurationData was dot-sourced above.
    #                     ConfigurationData    = $ConfigurationData
    #                 }

    #                 . $configFile
    #                 & $($script:configurationName) @configurationParameters


    #                 $startDscConfigurationParameters = @{
    #                     Path         = $TestDrive
    #                     ComputerName = 'localhost'
    #                     Wait         = $true
    #                     Verbose      = $true
    #                     Force        = $true
    #                     ErrorAction  = 'Stop'
    #                 }

    #                 Start-DscConfiguration @startDscConfigurationParameters
    #             } | Should -Not -Throw
    #         }

    #         It 'Should be able to call Get-DscConfiguration without throwing' {
    #             {
    #                 $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
    #             } | Should -Not -Throw
    #         }

    #         It 'Should have set the resource and all the parameters should match' {
    #             $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
    #                 $_.ConfigurationName -eq $configurationName `
    #                 -and $_.ResourceId -eq $resourceId
    #             }

    #             $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
    #             $resourceCurrentState.ProjectDescription | Should -Be 'TestProjectDescription'
    #         }

    #         It 'Should return $true when Test-DscConfiguration is run' {
    #             Test-DscConfiguration -Verbose | Should -Be 'True'
    #         }
    #     }



    #     $script:configurationName = "$($script:dscResourceName)_EnsureProjectUpdated_Config"
    #     $script:resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectUpdated"

    #     Context ('When using configuration {0}' -f $script:configurationName) {

    #         BeforeAll {
    #             $configurationName = "$($script:dscResourceName)_EnsureProjectUpdated_Config"
    #             $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_EnsureProjectUpdated"
    #         }

    #         It 'Should compile and apply the MOF without throwing' {
    #             {
    #                 $configurationParameters = @{
    #                     OutputPath           = $TestDrive
    #                     # The variable $ConfigurationData was dot-sourced above.
    #                     ConfigurationData    = $ConfigurationData
    #                 }

    #                 . $configFile
    #                 & $($script:configurationName) @configurationParameters


    #                 $startDscConfigurationParameters = @{
    #                     Path         = $TestDrive
    #                     ComputerName = 'localhost'
    #                     Wait         = $true
    #                     Verbose      = $true
    #                     Force        = $true
    #                     ErrorAction  = 'Stop'
    #                 }

    #                 Start-DscConfiguration @startDscConfigurationParameters
    #             } | Should -Not -Throw
    #         }

    #         It 'Should be able to call Get-DscConfiguration without throwing' {
    #             {
    #                 $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
    #             } | Should -Not -Throw
    #         }

    #         It 'Should have set the resource and all the parameters should match' {
    #             $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
    #                 $_.ConfigurationName -eq $configurationName `
    #                 -and $_.ResourceId -eq $resourceId
    #             }

    #             $resourceCurrentState.ProjectName | Should -Be 'TestProjectName'
    #             $resourceCurrentState.ProjectDescription | Should -Be 'AnAmendedProjectDescription'
    #         }

    #         It 'Should return $true when Test-DscConfiguration is run' {
    #             Test-DscConfiguration -Verbose | Should -Be 'True'
    #         }
    #     }
    # }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
