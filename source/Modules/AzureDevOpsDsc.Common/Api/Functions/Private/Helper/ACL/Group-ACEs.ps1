<#
.SYNOPSIS
    Groups Access Control Entries (ACEs) by identity and permissions.

.DESCRIPTION
    The Group-ACEs function takes an array of ACE objects and groups them by their identity.
    It then further groups the identities by their permissions. The function returns a list
    of grouped ACEs.

.PARAMETER ACEs
    An array of ACE objects to be grouped. Each ACE object should have an Identity and Permissions property.

.OUTPUTS
    System.Collections.Generic.List[HashTable]
    A list of hash tables where each hash table represents a grouped ACE with its identity and permissions.

.EXAMPLE
    $aces = Get-ACEs
    $groupedACEs = Group-ACEs -ACEs $aces
    Write-Output $groupedACEs

.NOTES
    The function uses verbose output to provide detailed information about its processing steps.
#>
Function Group-ACEs
{
    param(
        # Mandatory parameter: an array of ACE objects.
        [Parameter()]
        [Object[]]$ACEs
    )

    Write-Verbose "[Group-ACE] Started."

    # Check if the ACEs are not found.
    if (-not $ACEs)
    {
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
    ForEach ($item in $Multiple)
    {
        Write-Verbose "[Group-ACE] Processing multiple identity: $($item.Group[0].Identity)"

        # Create a new hash table for the group
        $ht = @{
            Identity    = $item.Group[0].Identity
            Permissions = @{
                Deny            = $item.Group.Permissions.Deny | Sort-Object -Unique Bit
                Allow           = $item.Group.Permissions.Allow | Sort-Object -Unique Bit
                DescriptorType  = $item.Group[0].Permissions.DescriptorType
            }
        }

        Write-Verbose "[Group-ACE] Adding grouped identity with permissions."

        $ACEList.Add($ht)
    }

    Write-Verbose "[Group-ACE] Completed."
    $ACEList

}
