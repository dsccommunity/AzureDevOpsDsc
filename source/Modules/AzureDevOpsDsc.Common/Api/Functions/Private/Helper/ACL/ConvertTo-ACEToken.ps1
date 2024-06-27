<#
.SYNOPSIS
Converts ACE permissions into an ACL token.

.DESCRIPTION
The ConvertTo-ACEToken function converts Access Control Entry (ACE) permissions into an ACL token. It takes a security namespace, an identity, and an array of ACE permissions objects as input parameters. It then initializes the ACL token, performs a lookup for the security descriptor, iterates through each ACE permission, filters allow and deny permissions, computes actions, and adds the computed hash table to the array. Finally, it returns the hashtable array.

.PARAMETER SecurityNamespace
The security namespace as a string. This parameter is mandatory.

.PARAMETER Identity
The identity associated with the ACE. This parameter is mandatory.

.PARAMETER ACEPermissions
An array of ACE permissions objects. This parameter is mandatory.

.EXAMPLE
$securityNamespace = "MySecurityNamespace"
$identity = "User1"
$acePermissions = @(
    @{
        Permission = @{
            Read = "Allow"
            Write = "Deny"
        }
    },
    @{
        Permission = @{
            Read = "Allow"
            Write = "Allow"
        }
    }
)

ConvertTo-ACEToken -SecurityNamespace $securityNamespace -Identity $identity -ACEPermissions $acePermissions

.NOTES
This function requires the Get-CacheItem cmdlet to be available in the session.

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-cacheitem?view=powershell-7.1

#>

Function ConvertTo-ACEToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$SecurityNamespace,

        [Parameter(Mandatory)]
        [string]$Identity,

        [Parameter(Mandatory)]
        [Object[]]$ACEPermissions
    )

    Write-Verbose "[ConvertTo-ACEToken] Initializing the ACL Token."
    $hashTableArray = [System.Collections.Generic.List[HashTable]]::new()

    Write-Verbose "[ConvertTo-ACEToken] Performing a Lookup for the Security Descriptor."
    Write-Verbose "[ConvertTo-ACEToken] Security Namespace: $SecurityNamespace"

    $SecurityDescriptor = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'

    # Check if the Security Descriptor was found
    if (-not $SecurityDescriptor) {
        Write-Error "Security Descriptor not found for namespace: $SecurityNamespace"
        return
    }

    Write-Verbose "[ConvertTo-ACEToken] Iterating through each of the ACE Permissions."
    ForEach ($ACEPermission in $ACEPermissions) {

        Write-Verbose "[ConvertTo-ACEToken] ACEPermission: $($ACEPermission | ConvertTo-Json)"
        Write-Verbose "[ConvertTo-ACEToken] Filtering Allow and Deny permissions."

        $AllowPermissions = $ACEPermission.Keys | Where-Object { $ACEPermission."$_" -eq 'Allow' }
        $DenyPermissions  = $ACEPermission.Keys | Where-Object { $ACEPermission."$_" -eq 'Deny'  }

        Write-Verbose "[ConvertTo-ACEToken] Iterating through the Allow and Deny Permissions and computing actions."
        $AllowBits = $SecurityDescriptor.actions | Where-Object { $_.displayName -in $AllowPermissions }
        $DenyBits  = $SecurityDescriptor.actions | Where-Object { $_.displayName -in $DenyPermissions }

        # Compute the bitwise OR for the permissions
        $hashTable = @{
            DescriptorType = $SecurityNamespace
            Allow          = BorArray -integers $AllowBits.bit
            Deny           = BorArray -integers $DenyBits.bit
        }

        Write-Verbose "[ConvertTo-ACEToken] Adding computed hash table to the array"
        $hashTableArray.Add($hashTable)
    }

    Write-Verbose "[ConvertTo-ACEToken] Completed processing ACE Permissions"

    # Return the hashtable array
    return $hashTableArray
}
