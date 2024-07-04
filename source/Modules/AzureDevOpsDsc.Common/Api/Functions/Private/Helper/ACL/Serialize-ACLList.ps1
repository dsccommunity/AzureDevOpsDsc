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
   Write-Verbose "Initializing the ACLs hashtable."
   $ACLs = @{
       Count = 0
       value = [System.Collections.Generic.List[Object]]::new()
   }

   # Filter out all ACLs that don't match the descriptor match token. These are needed to construct the ACLs object
   # Otherwise, the existing ACLs will be removed.
   Write-Verbose "Filtering descriptor ACLs that do not match the descriptor match token."
   $FilteredDescriptorACLS = $DescriptorACLList | Where-Object { $_.token -notmatch $DescriptorMatchToken }

   # Iterate through the filtered descriptor ACLs to construct the ACLs object
   Write-Verbose "Iterating through the filtered descriptor ACLs to construct the ACLs object."
   ForEach ($acl in $FilteredDescriptorACLS) {
       Write-Verbose "Adding filtered ACL to the ACLs object."
       $ACLs.value.Add($acl)
   }

   # Construct the ACLs object from the reference ACLs
   Write-Verbose "Constructing the ACLs object from the reference ACLs."

   # Iterate through the ACLs in the aclList
   ForEach ($acl in $ReferenceACLs) {
       Write-Verbose "Processing reference ACL."

       # Construct the ACL Object with properties inheritPermissions, token, and acesDictionary
       $ht = @{
           inheritPermissions = $acl.inherited
           token = Format-Token -Token $acl.token
           acesDictionary = @{}
       }

       # Iterate through the ACEs in the current ACL to construct the ACEs Dictionary
       ForEach ($ace in $acl.aces) {
           Write-Verbose "Constructing ACE Object."

           # Construct the ACE Object with properties allow, deny, and descriptor
           $newace = @{
               allow       = BorArray $ace.permissions.allow.bit
               deny        = BorArray $ace.permissions.deny.bit
               descriptor  = $ace.Identity.value.ACLIdentity.descriptor
           }
           # Add the ACE to the ACEs Dictionary using the descriptor as the key
           Write-Verbose "Adding ACE to the ACEs Dictionary."
           $ht.acesDictionary.Add($ace.Identity.value.ACLIdentity.descriptor, $newace)
       }

       # Add the constructed ACL object (ht) to the ACL List
       Write-Verbose "Adding constructed ACL object to the ACL List."
       $ACLs.value.Add($ht)
   }

   # Update the ACL Count with the number of ACLs in the list
   Write-Verbose "Updating the ACL Count."
   $ACLs.Count = $ACLs.value.Count

   # Return the constructed ACLs hashtable
   Write-Verbose "[Serialize-ACLList] Completed."
   Write-Output $ACLs

}
