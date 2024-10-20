<#
.SYNOPSIS
    This script contains unit tests for the New-AzDevOpsACLToken function.

.DESCRIPTION
    The New-AzDevOpsACLToken function is used to generate access tokens for Azure DevOps.
    It can generate project-level access tokens or team-level access tokens.

    This script contains unit tests to verify the behavior of the New-AzDevOpsACLToken function.

.NOTES
    Author: Your Name
    Date:   Current Date

.LINK
    https://link-to-documentation

.EXAMPLE
    Describe "New-AzDevOpsACLToken Tests" {
        Context "Project-level access token" {
            It "Returns the correct token without TeamId" {
                $OrganizationName = "MyOrg"
                $ProjectId = "1234"
                $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId
                $expectedToken = "vstfs:///Classification/TeamProject/$ProjectId"
                $result | Should -BeExactly $expectedToken
            }
        }

        Context "Team-level access token" {
            It "Returns the correct token with TeamId" {
                $OrganizationName = "MyOrg"
                $ProjectId = "1234"
                $TeamId = "abcd"
                $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId -TeamId $TeamId
                $expectedToken = "vstfs:///Classification/TeamProject/$ProjectId/$TeamId"
                $result | Should -BeExactly $expectedToken
            }
        }
    }
#>

. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {
    Describe "New-AzDevOpsACLToken Tests" {
        Context "Project-level access token" {
            It "Returns the correct token without TeamId" {
                $OrganizationName = "MyOrg"
                $ProjectId = "1234"
                $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId
                $expectedToken = "vstfs:///Classification/TeamProject/$ProjectId"
                $result | Should -BeExactly $expectedToken
            }
        }

        Context "Team-level access token" {
            It "Returns the correct token with TeamId" {
                $OrganizationName = "MyOrg"
                $ProjectId = "1234"
                $TeamId = "abcd"
                $result = New-AzDevOpsACLToken -OrganizationName $OrganizationName -ProjectId $ProjectId -TeamId $TeamId
                $expectedToken = "vstfs:///Classification/TeamProject/$ProjectId/$TeamId"
                $result | Should -BeExactly $expectedToken
            }
        }
    }
}
