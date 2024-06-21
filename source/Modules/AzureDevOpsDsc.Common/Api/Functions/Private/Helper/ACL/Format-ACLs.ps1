Function Format-ACLs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Object[]]$ACLs,
        [Parameter(Mandatory)]
        [HashTable]$DescriptorType
    )

    #
    # Logging
    Write-Verbose "[Format-ACL] Started."

    $formattedACLs = [System.Collections.Generic.List[HashTable]]::new()

    #
    # Iterate through the ACLs

    foreach ($ACL in $ACLs) {

        # Create a new ACL Object
        $ACEs = [System.Collections.Generic.List[HashTable]]::new()

        # Enumerate the ACE Names
        $ACEEntries = $ACLs.acesDictionary.psObject.properties.name
        # Retirve the ACL Name and Value
        $ACEEntries | ForEach-Object {
            $ACEs.Add([HashTable]@{
                Name = $_
                Value = $ACL."$($_)"
            })
        }

        # Match the Identity with the ACE
        foreach ($ACE in $ACEs) {
            # Find the Identity and attach to the ACE
            $ACE."Identity" = Find-Identity -Name $ACE.Name
            # Format the ACE
            $ACE."Permissions" = Format-ACEs -Allow $ACE.value.allow -Deny $ACE.value.deny -Type $DescriptorType
        }

        # Add the ACL to the new ACLs
        $formattedACLs.Add([HashTable]@{
            token = Resolve-ACLToken -Token $ACL.token
            inherited = $ACL.inheritPermissions
            aces = $ACEs
        })

    }

    # Return the Formatted ACLs
    return $formattedACLs

}
