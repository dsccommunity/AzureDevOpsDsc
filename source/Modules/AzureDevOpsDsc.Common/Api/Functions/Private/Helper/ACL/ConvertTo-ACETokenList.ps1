

Function ConvertTo-ACETokenList
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespace,

        [Parameter(Mandatory = $true)]
        [Object[]]$ACEPermissions
    )

    Write-Verbose "[ConvertTo-ACETokenList] Initializing the ACL Token."
    $hashTableArray = [System.Collections.Generic.List[HashTable]]::new()

    Write-Verbose "[ConvertTo-ACETokenList] Performing a Lookup for the Security Descriptor."
    Write-Verbose "[ConvertTo-ACETokenList] Security Namespace: $SecurityNamespace"

    $SecurityDescriptor = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'

    # Check if the Security Descriptor was found
    if (-not $SecurityDescriptor)
    {
        Write-Error "Security Descriptor not found for namespace: $SecurityNamespace"
        return
    }

    # Iterate through each of the ACEs and construct the ACE Object
    Write-Verbose "[ConvertTo-ACETokenList] Iterating through each of the ACE Permissions."

    ForEach ($ACEPermission in $ACEPermissions)
    {
        # Check to see if there are any permissions that are not found in the Security Descriptor
        $missingPermissions = $ACEPermission.Keys | Where-Object {
            ($_ -notin $SecurityDescriptor.actions.displayName) -and
            ($_ -notin $SecurityDescriptor.actions.name)
        } | ForEach-Object {
            Write-Verbose "[ConvertTo-ACETokenList] Permission '$_' not found in the Security Descriptor for namespace: $SecurityNamespace"
        }

        # Filter the Allow and Deny permissions
        Write-Verbose "[ConvertTo-ACETokenList] ACEPermission: $($ACEPermission | ConvertTo-Json)"
        Write-Verbose "[ConvertTo-ACETokenList] Filtering Allow and Deny permissions."

        $AllowPermissions = $ACEPermission.Keys | Where-Object { $ACEPermission."$_" -eq 'Allow' }
        $DenyPermissions  = $ACEPermission.Keys | Where-Object { $ACEPermission."$_" -eq 'Deny'  }

        Write-Verbose "[ConvertTo-ACETokenList] Iterating through the Allow and Deny Permissions and computing actions."
        $AllowBits = $SecurityDescriptor.actions | Where-Object { ($_.displayName -in $AllowPermissions) -or ($_.name -in $AllowPermissions) }
        $DenyBits  = $SecurityDescriptor.actions | Where-Object { ($_.displayName -in $DenyPermissions) -or ($_.name -in $DenyPermissions) }

        # Compute the bitwise OR for the permissions
        $hashTable = @{
            DescriptorType = $SecurityNamespace
            Allow          = $AllowBits
            Deny           = $DenyBits
        }

        Write-Verbose "[ConvertTo-ACETokenList] Adding computed hash table to the array"
        Write-Verbose "[ConvertTo-ACETokenList] Hash Table: $($hashTable | ConvertTo-Json)"
        $hashTableArray.Add($hashTable)
    }

    Write-Verbose "[ConvertTo-ACETokenList] Completed processing ACE Permissions"

    # Return the hashtable array
    return $hashTableArray

}
