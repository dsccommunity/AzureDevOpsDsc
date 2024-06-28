Function Group-ACEs {
    param(
        # Mandatory parameter: an array of ACE objects.
        [Parameter()]
        [Object[]]$ACEs
    )

    Write-Verbose "[Group-ACE] Started."

    # Check if the ACEs are not found.
    if (-not $ACEs) {
        Write-Verbose "[Group-ACE] ACEs not found."
        return
    }

    Write-Verbose "[Group-ACE] Initializing empty list to hold the ACEs."

    # Initialize an empty list to hold the ACEs (Access Control Entries).
    $ACEList = [System.Collections.Generic.List[HashTable]]::new()

    Write-Verbose "[Group-ACE] Grouping the ACEs by identity."

    # Group the ACEs by the identity.
    $GroupedIdentities = $ACEs | Group-Object -Property { $_.Identity.value.originId }

    Write-Verbose "[Group-ACE] Filtering groups based on count."

    # Filter by the count
    $Single, $Multiple = $GroupedIdentities.Where({ $_.Count -eq 1 }, 'Split')

    Write-Verbose "[Group-ACE] Adding single identities to the ACE list."

    # Add the single identities to the ACE list
    $Single | ForEach-Object {
        Write-Verbose "[Group-ACE] Adding single identity: $($_.Group[0].Identity)"
        $ACEList.Add($_.Group[0])
    }

    Write-Verbose "[Group-ACE] Grouping multiple identities by permissions."

    # Group the multiple identities by the permissions
    $Multiple | ForEach-Object {

        Write-Verbose "[Group-ACE] Processing multiple identity: $($_.Group[0].Identity)"

        # Create a new hash table for the group
        $ht = @{
            Identity    = $_.Group[0].Identity
            Permissions = @{
                Deny            = BorArray $_.Group.Permissions.Deny
                Allow           = BorArray $_.Group.Permissions.Allow
                DescriptorType  = $_.Group[0].Permissions.DescriptorType
            }
        }

        Write-Verbose "[Group-ACE] Adding grouped identity with permissions."

        $ACEList.Add($ht)
    }

    Write-Verbose "[Group-ACE] Completed."
    $ACEList

}
