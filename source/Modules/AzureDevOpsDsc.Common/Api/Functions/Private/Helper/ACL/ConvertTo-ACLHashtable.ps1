<#
.SYNOPSIS
Serializes the ACL list based on the provided reference ACLs, descriptor ACL list, and descriptor match token.

.DESCRIPTION
The ConvertTo-ACLHashtable function captures the ACLs that are relevant to the Git Repository by matching the descriptor match token. If the descriptor ACL list is empty, it falls back to using the reference ACLs. It then constructs an ACL object for each ACL in the ACL list, including properties like inheritPermissions, token, and acesDictionary. The acesDictionary contains ACE objects with properties like allow, deny, and descriptor. Finally, it returns the constructed ACLs hashtable.

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

ConvertTo-ACLHashtable -ReferenceACLs $referenceACLs -DescriptorACLList $descriptorACLList -DescriptorMatchToken $descriptorMatchToken

.OUTPUTS
System.Collections.Hashtable
The constructed ACLs hashtable containing the serialized ACLs.
#>

Function ConvertTo-ACLHashtable {
    param(
        [Parameter()]
        [Object[]]
        $ReferenceACLs,

        [Parameter(Mandatory)]
        [Object[]]
        $DescriptorACLList,

        [Parameter(Mandatory)]
        [String]
        $DescriptorMatchToken
    )

    # Convert the ReferenceACLs to an array if it is not already an array
    $ReferenceACLs = [Array]$ReferenceACLs

    Write-Verbose "[ConvertTo-ACLHashtable] Started."
    Write-Verbose "[ConvertTo-ACLHashtable] Reference ACLs: $($ReferenceACLs | ConvertTo-Json -Depth 3)"
    Write-Verbose "[ConvertTo-ACLHashtable] Descriptor ACL List: $($DescriptorACLList | ConvertTo-Json -Depth 3)"
    Write-Verbose "[ConvertTo-ACLHashtable] Descriptor Match Token: $DescriptorMatchToken"

    # Initialize the ACLs hashtable with a count and a list to hold ACL objects
    Write-Verbose "[ConvertTo-ACLHashtable] Initializing the ACLs hashtable."
    $ACLHashtable = @{
        Count = 0
        value = [System.Collections.Generic.List[Object]]::new()
    }

    # Filter out all ACLs that don't match the descriptor match token. These are needed to construct the ACLs object
    # Otherwise, the existing ACLs will be removed.
    Write-Verbose "[ConvertTo-ACLHashtable] Filtering descriptor ACLs that do not match the descriptor match token."
    $FilteredDescriptorACLs = $DescriptorACLList | Where-Object { $_.token -notmatch $DescriptorMatchToken }

    # Iterate through the filtered descriptor ACLs to construct the ACLs object
    Write-Verbose "[ConvertTo-ACLHashtable] Iterating through the filtered descriptor ACLs to construct the ACLs object."
    ForEach ($DescriptorACL in $FilteredDescriptorACLs) {
        Write-Verbose "Adding filtered ACL to the ACLs object."
        $ACLHashtable.value.Add($DescriptorACL)
    }

    # Construct the ACLs object from the reference ACLs
    Write-Verbose "[ConvertTo-ACLHashtable] Constructing the ACLs object from the reference ACLs."

    # Iterate through the ACLs in the ReferenceACLs
    ForEach ($ReferenceACL in $ReferenceACLs) {
        Write-Verbose "[ConvertTo-ACLHashtable] Processing reference ACL."
        Write-Verbose "[ConvertTo-ACLHashtable] Reference ACL: $($ReferenceACL | ConvertTo-Json -Depth 3)"

        # Construct the ACL Object with properties inheritPermissions, token, and acesDictionary
        $ACLObject = [PSCustomObject]@{
            inheritPermissions = $ReferenceACL.inherited
            token = ConvertTo-FormattedToken -Token $ReferenceACL.token
            acesDictionary = @{}
        }

        # Iterate through the ACEs in the current ACL to construct the ACEs Dictionary
        ForEach ($ACE in $ReferenceACL.aces) {
            Write-Verbose "[ConvertTo-ACLHashtable] Constructing ACE Object."

            # Construct the ACE Object with properties allow, deny, and descriptor
            $ACEObject = @{
                allow       = Get-BitwiseOrResult $ACE.permissions.allow.bit
                deny        = Get-BitwiseOrResult $ACE.permissions.deny.bit
                descriptor  = $ACE.Identity.value.ACLIdentity.descriptor
            }
            # Add the ACE to the ACEs Dictionary using the descriptor as the key
            Write-Verbose "[ConvertTo-ACLHashtable] ACEObject $($ACEObject | ConvertTo-Json)."
            Write-Verbose "[ConvertTo-ACLHashtable] Adding ACE to the ACEs Dictionary."

            $ACLObject.acesDictionary.Add($ACE.Identity.value.ACLIdentity.descriptor, $ACEObject)
        }

        # Add the constructed ACL object (ACLObject) to the ACL List
        Write-Verbose "[ConvertTo-ACLHashtable] Adding constructed ACL object to the ACL List."
        $ACLHashtable.value.Add($ACLObject)
    }

    # Update the ACL Count with the number of ACLs in the list
    Write-Verbose "[ConvertTo-ACLHashtable] Updating the ACL Count."
    $ACLHashtable.Count = $ACLHashtable.value.Count

    # Return the constructed ACLs hashtable
    Write-Verbose "[ConvertTo-ACLHashtable] Completed."
    Write-Output $ACLHashtable
}
