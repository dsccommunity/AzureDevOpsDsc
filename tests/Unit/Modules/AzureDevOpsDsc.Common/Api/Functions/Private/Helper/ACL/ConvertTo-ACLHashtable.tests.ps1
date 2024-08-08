powershell
# Import the Pester module
Import-Module Pester

# Mock functions to simplify testing
Mock ConvertTo-FormattedToken { param ($Token) return $Token }
Mock Get-BitwiseOrResult { param ($bit) return $bit }

# Define the test cases
$referenceACLs = @(
    [PSCustomObject]@{
        token = "token1"
        inheritPermissions = $true
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
        aces = @(
            [PSCustomObject]@{
                permissions = @{
                    allow = @{
                        bit = 0
                    }
                    deny = @{
                        bit = 1
                    }
                }
                Identity = @{
                    value = @{
                        ACLIdentity = @{
                            descriptor = "descriptor2"
                        }
                    }
                }
            }
        )
    }
)

$descriptorMatchToken = "token2"

# Test to ensure the function handles the provided parameters correctly and returns the expected hashtable
Describe "ConvertTo-ACLHashtable" {
    It "Correctly converts and builds the ACL hashtable" {
        $result = ConvertTo-ACLHashtable -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken
        
        $expectedResult = @{
            Count = 2
            value = [System.Collections.Generic.List[Object]]::new()
        }

        $expectedResult.value.Add($descriptorACLList[0])
        
        $expectedResult.value.Add([PSCustomObject]@{
            inheritPermissions = $true
            token = "token1"
            acesDictionary = @{
                "descriptor1" = @{
                    allow = 1
                    deny = 0
                    descriptor = "descriptor1"
                }
            }
        })

        $result | Should -BeExactly $expectedResult
    }
}

Be sure you've installed and imported the Pester module version 5 before running this test. You can do so by running `Install-Module -Name Pester -Force`, then `Import-Module Pester`.
