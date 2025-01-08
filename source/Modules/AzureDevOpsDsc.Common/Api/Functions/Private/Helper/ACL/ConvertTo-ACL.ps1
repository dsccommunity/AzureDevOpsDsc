<#
.SYNOPSIS
Converts an array of hash tables containing permissions into a list of Access Control Lists (ACLs).

.DESCRIPTION
The ConvertTo-ACL function takes an array of hash tables containing permissions and converts them into a list of Access Control Lists (ACLs). Each permission in the array must contain 'Identity' and 'Permissions' keys. The function creates an ACL token and ACE (Access Control Entry) for each permission, and then adds them to the ACL list. The ACL list is returned as the output of the function.

.PARAMETER Permissions
Mandatory parameter. An array of hash tables containing permissions. Each permission must contain 'Identity' and 'Permissions' keys.

.PARAMETER SecurityNamespace
Mandatory parameter. The security namespace as a string.

.PARAMETER isInherited
Mandatory parameter. Boolean indicating if the ACL is inherited.

.PARAMETER OrganizationName
Mandatory parameter. The organization name as a string.

.EXAMPLE
$permissions = @(
    @{
        Identity    = 'User1'
        Permissions = 'Read'
    },
    @{
        Identity    = 'User2'
        Permissions = 'Read', 'Write'
    }
)

ConvertTo-ACL -Permissions $permissions -SecurityNamespace 'Namespace1' -isInherited $true -OrganizationName 'Org1'

This example converts an array of permissions into ACLs for a specific security namespace and organization.

.OUTPUTS
System.Collections.Generic.List[HashTable]
A list of Access Control Lists (ACLs) created from the provided permissions.

.NOTES
Author: Michael Zanatta
Date: 2025-01-06
#>
Function ConvertTo-ACL
{
    [CmdletBinding()]
    param (
        # Mandatory parameter: an array of hash tables containing permissions.
        [Parameter()]
        [HashTable[]]$Permissions=@(),

        # Mandatory parameter: the security namespace as a string.
        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespace,

        # Mandatory parameter: boolean indicating if the ACL is inherited.
        [Parameter(Mandatory = $true)]
        [bool]$isInherited,

        # Mandatory parameter: the organization name as a string.
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        # Mandatory parameter: the token name as a string.
        [Parameter(Mandatory = $true)]
        [string]$TokenName
    )

    # Verbose output indicating the start of the function.
    Write-Verbose "[ConvertTo-ACL] Started."

    # Create a hash table for ACL token parameters.
    $ACLTokenParams = @{
        SecurityNamespace  = $SecurityNamespace
        TokenName          = $TokenName
    }

    Write-Verbose "[ConvertTo-ACL] ACL Token Params: $($ACLTokenParams | Out-String)"

    # Create a hash table for ACE parameters.
    $ACEParams = @{
        SecurityNamespace = $SecurityNamespace
        Permissions       = $Permissions
        OrganizationName  = $OrganizationName
    }

    Write-Verbose "[ConvertTo-ACL] ACE Params: $($ACEParams | Out-String)"

    # Convert the Permission to an ACL Token and create the ACL hash table.
    $ACL = @{
        token     = New-ACLToken @ACLTokenParams
        aces      = ConvertTo-ACEList @ACEParams
        inherited = $isInherited
    }

    # If the ACEs are empty, write a warning and return.
    if ($ACL.aces.Count -eq 0)
    {
        Write-Warning "[ConvertTo-ACL] No ACEs were created. Returning."
        return $ACL
    }

    # Group the ACEs by the identity removing any duplicates.
    $ACL.aces = Group-ACEs -ACEs $ACL.aces

    Write-Verbose "[ConvertTo-ACL] Created ACL: $($ACL | Out-String)"

    # Verbose output indicating the completion of the function.
    Write-Verbose "[ConvertTo-ACL] Completed. Returning ACLs."

    # Return the list of ACLs.
    return $ACL
}
