Function Format-ACL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Object]$ACL,
        [Parameter(Mandatory)]
        [String]$SecurityNamespace
    )

    #
    # Logging
    Write-Verbose "[Format-ACL] Started."

    Write-Verbose "[Format-ACL] Processing ACL: $($ACL.token)"

    # Create a new ACL Object
    $ACEs = [System.Collections.Generic.List[HashTable]]::new()

    # Enumerate the ACE Names
    $ACEEntries = $ACL.acesDictionary.psObject.properties.name
    Write-Verbose "[Format-ACL] Found ACE entries: $($ACEEntries.Count)"

    # Retrieve the ACL Name and Value
    $ACEEntries | ForEach-Object {
        Write-Verbose "[Format-ACL] Processing ACE entry: $_"
        $ACEs.Add([HashTable]@{
            Name = $_
            Value = $ACL.acesDictionary."$($_)"
        })
    }

    Write-Verbose "[Format-ACL] Found ACEs: $($ACEs.Count)"

    #
    # Create the Formatted ACL Object

    # Match the Identity with the ACE
    foreach ($ACE in $ACEs) {
        Write-Verbose "[Format-ACL] Matching identity for ACE: $($ACE.Name)"
        # Find the Identity and attach to the ACE
        $ACE."Identity" = Find-Identity -Name $ACE.Name

        Write-Verbose "[Format-ACL] Formatting ACE: $($ACE.Name) - Allow $($ACE.value.allow) - Deny $($ACE.value.allow)"
        # Format the ACE
        $ACE."Permissions" = Format-ACEs -Allow $ACE.value.allow -Deny $ACE.value.allow -SecurityNamespace $SecurityNamespace
    }

    # Add the ACL to the new ACL
    Write-Verbose "[Format-ACL] Adding formatted ACL: $($ACL.token)"

    $formattedACL = [HashTable]@{
        token = Resolve-ACLToken -Token $ACL.token
        inherited = $ACL.inheritPermissions
        aces = $ACEs
    }

    # Return the Formatted ACL
    Write-Verbose "[Format-ACL] Completed."
    return $formattedACL

}
