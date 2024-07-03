<#
.SYNOPSIS
Serializes the ACL list based on the provided reference ACLs, descriptor ACL list, and descriptor match token.

.DESCRIPTION
The Serialize-ACLList function captures the ACLs that are relevant to the Git Repository by matching the descriptor match token. If the descriptor ACL list is empty, it falls back to using the reference ACLs. It then constructs an ACL object for each ACL in the ACL list, including properties like inheritPermissions, token, and acesDictionary. The acesDictionary contains ACE objects with properties like allow, deny, and descriptor. Finally, it returns the constructed ACLs hashtable.

.PARAMETER ReferenceACLs
The reference ACLs to be used as a fallback if the descriptor ACL list is empty.

.PARAMETER DescriptorACLList
The descriptor ACL list containing the ACLs relevant to the Git Repository.

.PARAMETER DescriptorMatchToken
The descriptor match token used to filter the ACLs relevant to the Git Repository.

.EXAMPLE
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

Serialize-ACLList -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken

.OUTPUTS
System.Collections.Hashtable
The constructed ACLs hashtable containing the serialized ACLs.

#>

Function Serialize-ACLList {
    param(
        [Parameter(Mandatory)]
        [Object[]]
        $ReferenceACLs,

        [Parameter(Mandatory)]
        [Object[]]
        $DescriptorACLList,

        [Parameter(Mandatory)]
        [String]
        $DescriptorMatchToken
    )

    Write-Verbose "[Serialize-ACLList] Started."

    # Initialize the ACLs hashtable with a count and a list to hold ACL objects
    $ACLs = @{
        Count = 0
        value = [System.Collections.Generic.List[Object]]::new()
    }

    # Capture the ACLs that are relevant to the Git Repository by matching the token
    $aclList = $DescriptorACLList | Where-Object { $_.token -match $DescriptorMatchToken }

    # If the aclList is empty, use the Reference ACLs as a fallback
    if ($aclList.Count -eq 0) {
        $aclList = $ReferenceACLs | Where-Object { $_.token -match $DescriptorMatchToken }
    }

    # Iterate through the ACLs in the aclList
    ForEach ($acl in $aclList) {

        # Construct the ACL Object with properties inheritPermissions, token, and acesDictionary
        $ht = @{
            inheritPermissions = $acl.inheritPermissions
            token = Format-Token -Token $acl.token
            acesDictionary = @{}
        }

        # Iterate through the ACEs in the current ACL to construct the ACEs Dictionary
        ForEach ($ace in $acl.aces) {

            # Construct the ACE Object with properties allow, deny, and descriptor
            $ACE = @{
                allow       = BorArray $ace.permissions.allow.bit
                deny        = BorArray $ace.permissions.deny.bit
                descriptor  = $ace.Identity.value.ACLIdentity.descriptor
            }
            # Add the ACE to the ACEs Dictionary using the descriptor as the key
            $ht.acesDictionary.Add($ace.Identity.value.ACLIdentity.descriptor, $ACE)
        }

        # Add the constructed ACL object (ht) to the ACL List
        $ACLs.value.Add($ht)
    }

    # Update the ACL Count with the number of ACLs in the list
    $ACLs.Count = $ACLs.value.Count

    # Return the constructed ACLs hashtable
    Write-Output $ACLs
}
