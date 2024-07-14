
Describe "ConvertTo-ACLHashtable" {
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

    It "should return an ACL Hashtable with correct structure and values" {
        $result = ConvertTo-ACLHashtable -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken

        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType Hashtable
        $result.ContainsKey('Count') | Should -BeTrue
        $result.ContainsKey('value') | Should -BeTrue
        $result.Count | Should -Be 1

        $acl = $result.value[0]
        $acl.token | Should -Be "token2"
        $acl.acesDictionary.ContainsKey("descriptor2") | Should -BeTrue

        $ace = $acl.acesDictionary['descriptor2']
        $ace.allow | Should -Be 0
        $ace.deny | Should -Be 1
    }

    It "should handle empty descriptor ACL list and use reference ACLs" {
        $descriptorACLList = @()
        $result = ConvertTo-ACLHashtable -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken

        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType Hashtable
        $result.ContainsKey('Count') | Should -BeTrue
        $result.ContainsKey('value') | Should -BeTrue
        $result.Count | Should -Be 1

        $acl = $result.value[0]
        $acl.token | Should -Be "token1"
        $acl.acesDictionary.ContainsKey("descriptor1") | Should -BeTrue

        $ace = $acl.acesDictionary['descriptor1']
        $ace.allow | Should -Be 1
        $ace.deny | Should -Be 0
    }

    It "should return empty ACL Hashtable for unmatched descriptor match token" {
        $descriptorMatchToken = "non-existent"
        $result = ConvertTo-ACLHashtable -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken

        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType Hashtable
        $result.ContainsKey('Count') | Should -BeTrue
        $result.ContainsKey('value') | Should -BeTrue
        $result.Count | Should -Be 0
    }
}

