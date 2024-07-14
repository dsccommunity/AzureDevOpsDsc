# Save this script as Test-WaitAzDevOpsApiResource.Tests.ps1

# Mocking the functions used within Wait-AzDevOpsApiResource
function Test-AzDevOpsApiUri { param([string]$ApiUri, [switch]$IsValid); return $true }
function Test-AzDevOpsApiVersion { param([string]$ApiVersion, [switch]$IsValid); return $true }
function Test-AzDevOpsPat { param([string]$Pat, [switch]$IsValid); return $true }
function Test-AzDevOpsApiResourceName { param([string]$ResourceName, [switch]$IsValid); return $true }
function Test-AzDevOpsApiResourceId { param([string]$ResourceId, [switch]$IsValid); return $true }
function Get-AzDevOpsApiVersion { param(); return '6.0' }
function Get-AzDevOpsApiWaitIntervalMs { return 1000 }
function Get-AzDevOpsApiWaitTimeoutMs { return 60000 }
function Test-AzDevOpsApiResource { param([string]$ApiUri, [string]$Pat, [string]$ResourceName, [string]$ResourceId); return $global:resourceExists }
function Test-AzDevOpsApiTimeoutExceeded { param([datetime]$StartTime, [datetime]$End, [int]$TimeoutMs); return $false }

# Import the module or script containing the function
. .\Path\To\Your\Script.ps1

Describe "Wait-AzDevOpsApiResource" {

    BeforeEach {
        $global:resourceExists = $false
    }

    Context "When waiting for resource to be present" {

        It "should complete successfully if resource becomes present" {
            $global:resourceExists = $false
            Start-Job -ScriptBlock {
                Start-Sleep -Seconds 2
                $global:resourceExists = $true
            } | Out-Null

            { Wait-AzDevOpsApiResource -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                                       -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId '1234' `
                                       -IsPresent } | Should -Not -Throw
        }

        It "should throw an error if timeout is exceeded while waiting for presence" {
            function Test-AzDevOpsApiTimeoutExceeded { param([datetime]$StartTime, [datetime]$End, [int]$TimeoutMs); return $true }

            { Wait-AzDevOpsApiResource -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                                       -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId '1234' `
                                       -IsPresent } | Should -Throw
        }
    }

    Context "When waiting for resource to be absent" {

        It "should complete successfully if resource becomes absent" {
            $global:resourceExists = $true
            Start-Job -ScriptBlock {
                Start-Sleep -Seconds 2
                $global:resourceExists = $false
            } | Out-Null

            { Wait-AzDevOpsApiResource -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                                       -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId '1234' `
                                       -IsAbsent } | Should -Not -Throw
        }

        It "should throw an error if timeout is exceeded while waiting for absence" {
            function Test-AzDevOpsApiTimeoutExceeded { param([datetime]$StartTime, [datetime]$End, [int]$TimeoutMs); return $true }

            { Wait-AzDevOpsApiResource -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                                       -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId '1234' `
                                       -IsAbsent } | Should -Throw
        }
    }

    Context "Parameter validation" {

        It "should throw an error if neither -IsPresent nor -IsAbsent switch is used" {
            { Wait-AzDevOpsApiResource -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                                       -Pat 'YourPatHere' -ResourceName 'Project' -ResourceId '1234' } | Should -Throw
        }
    }
}
