$currentFile = $MyInvocation.MyCommand.Path

# Test to ensure the function handles the provided parameters correctly and returns the expected hashtable
Describe "ConvertTo-ACLHashtable" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-ACLHashtable.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mock functions to simplify testing
        Mock -CommandName Write-Verbose
        Mock -CommandName ConvertTo-FormattedToken -MockWith { param ($Token) return $Token }
        Mock -CommandName Get-BitwiseOrResult -MockWith {
            param ($integers)
            return $integers
        }

        # Define the test cases
        $referenceACLs = @(
            [PSCustomObject]@{
                token = "token2"
                inherited = $true
                aces = @(
                    [PSCustomObject]@{
                        permissions = @{
                            allow = @{
                                bit = 1
                            }
                            deny = @{
                                bit = 0
                            }
                        }
                        Identity = @{
                            value = @{
                                ACLIdentity = @{
                                    descriptor = "descriptor1"
                                }
                            }
                        }
                    }
                )
            }
        )

        $descriptorACLList = @(
            [PSCustomObject]@{
                token = "token2"
                inheritPermissions = $false
                acesDictionary = @{
                    descriptor2 = @{
                        allow = 0
                        deny = 1
                    }

                }
            },
            [PSCustomObject]@{
                token = "token3"
                inheritPermissions = $true
                acesDictionary = @{
                    descriptor3 = @{
                        allow = 1
                        deny = 0
                    }
                }
            }
        )

        $descriptorMatchToken = "token2"

    }

    It "Correctly converts and builds the ACL hashtable" {
        $result = ConvertTo-ACLHashtable -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken

        $result.Count | Should -Be 2
        $result.value[0].token | Should -Be 'token3'
        $result.value[0].inheritPermissions | Should -Be $true
        $result.value[0].acesDictionary.descriptor3 | Should -Not -BeNullOrEmpty
        $result.value[0].acesDictionary.descriptor3.allow | Should -Be 1
        $result.value[0].acesDictionary.descriptor3.deny | Should -Be 0

        $result.value[1].token | Should -Be 'token2'
        $result.value[1].inheritPermissions | Should -Be $true
        $result.value[1].acesDictionary.descriptor1 | Should -Not -BeNullOrEmpty
        $result.value[1].acesDictionary.descriptor1.allow | Should -Be 1
        $result.value[1].acesDictionary.descriptor1.deny | Should -Be 0

    }
}

# End of Pester tests for ConvertTo-ACLHashtable

# Be sure you've installed and imported the Pester module version 5 before running this test.
# You can do so by running `Install-Module -Name Pester -Force`, then `Import-Module Pester`.
