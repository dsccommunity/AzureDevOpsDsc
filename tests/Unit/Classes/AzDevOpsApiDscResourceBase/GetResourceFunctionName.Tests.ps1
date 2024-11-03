
Describe "[AzDevOpsApiDscResourceBase]::GetResourceFunctionName() Tests" -Tag 'Unit', 'AzDevOpsApiDscResourceBase' {

    $testCasesValidRequiredActionWithFunctions = @(
        @{
            RequiredAction = 'Get'
        },
        @{
            RequiredAction = 'New'
        },
        @{
            RequiredAction = 'Set'
        },
        @{
            RequiredAction = 'Remove'
        },
        @{
            RequiredAction = 'Test'
        }
    )

    $testCasesValidRequiredActionWithoutFunctions = @(
        @{
            RequiredAction = 'Error'
        },
        @{
            RequiredAction = 'None'
        }
    )

    $testCasesInvalidRequiredActions = @(
        @{
            RequiredAction = 'SomethingInvalid'
        },
        @{
            RequiredAction = $null
        },
        @{
            RequiredAction = ''
        }
    )


    class AzDevOpsApiDscResourceBaseExample : AzDevOpsApiDscResourceBase # Note: Ignore 'TypeNotFound' warning (it is available at runtime)
    {
        [DscProperty(Key)]
        [string]$DscKey

        [string]GetResourceName()
        {
            return 'ApiDscResourceBaseExample'
        }
    }


    Context 'When called with valid "RequiredAction" values' {

        Context 'When "RequiredAction" value should have a related function' {

            It 'Should not throw - <RequiredAction>' -TestCases $testCasesValidRequiredActionWithFunctions {
                param ([System.String]$RequiredAction)

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

                {$azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction)} | Should -Not -Throw
            }

            It 'Should return the correct, function name - "<RequiredAction>"' -TestCases $testCasesValidRequiredActionWithFunctions {
                param ([System.String]$RequiredAction)

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

                $azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction) | Should -Be "$($RequiredAction)-ApiDscResourceBaseExample"
            }
        }


        Context 'When "RequiredAction" value should not have a related function' {

            It 'Should not throw - <RequiredAction>' -TestCases $testCasesValidRequiredActionWithoutFunctions {
                param ([System.String]$RequiredAction)

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

                {$azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction)} | Should -Not -Throw
            }

            It 'Should return the correct, function name - "<RequiredAction>"' -TestCases $testCasesValidRequiredActionWithoutFunctions {
                param ([System.String]$RequiredAction)

                $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

                $azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction) | Should -BeNullOrEmpty
            }
        }
    }


    Context 'When called with invalid "RequiredAction" values' {

        It 'Should not throw - <RequiredAction>' -TestCases $testCasesInvalidRequiredActions {
            param ([System.String]$RequiredAction)

            $azDevOpsApiDscResourceBase = [AzDevOpsApiDscResourceBaseExample]::new()

            {$azDevOpsApiDscResourceBase.GetResourceFunctionName($RequiredAction)} | Should -Throw
        }
    }
}

