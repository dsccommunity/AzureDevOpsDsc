<#
.SYNOPSIS
Converts permissions to an Access Control Entry (ACE) token.

.DESCRIPTION
The ConvertTo-ACEList function converts permissions to an Access Control Entry (ACE) token. It takes the security namespace, identity, an array of permissions objects, and the organization name as mandatory parameters. It constructs the ACE token for each permission and adds it to the list of ACEs.

.PARAMETER SecurityNamespace
The security namespace as a string. This parameter is mandatory.

.PARAMETER Identity
The identity associated with the ACE. This parameter is mandatory.

.PARAMETER Permissions
An array of permissions objects. This parameter is mandatory.

.PARAMETER OrganizationName
The organization name as a string. This parameter is mandatory.

.EXAMPLE
ConvertTo-ACEList -SecurityNamespace "Namespace" -Identity "User1" -Permissions @("Read", "Write") -OrganizationName "MyOrg"

This example converts the permissions "Read" and "Write" for the identity "User1" in the specified security namespace and organization name to an ACE token.

.NOTES
Author: Your Name
Date: Today's Date
#>

Function ConvertTo-ACEList {
    [CmdletBinding()]
    param (
        # Mandatory parameter: the security namespace as a string.
        [Parameter(Mandatory)]
        [string]$SecurityNamespace,

        # Mandatory parameter: an array of permissions objects.
        [Parameter()]
        [Object[]]$Permissions = @(),

        # Mandatory parameter: the organization name as a string.
        [Parameter(Mandatory)]
        [string]$OrganizationName
    )

    # Log the start of the function.
    Write-Verbose "[New-ACLToken] Started."

    # Initialize an empty list to hold the ACEs (Access Control Entries).
    $ACEs = [System.Collections.Generic.List[HashTable]]::new()

    # Iterate through each of the permissions and construct the ACE token.
    ForEach ($Permission in $Permissions) {

        # Define the parameters for the Find-Identity function.
        $indentityParams = @{
            # The name of the identity to search for. Remove any square brackets (e.g., [TEAM FOUNDATION]\Project Collection Administrators).
            Name             = $Permission.Identity.Replace('[', '').Replace(']', '')
            OrganizationName = $OrganizationName
            SearchType       = 'principalName'
        }

        # Define the parameters for the ACE Token.
        $aceTokenParams = @{
            SecurityNamespace = $SecurityNamespace
            Identity          = $Permission.Identity
            ACEPermissions    = $Permission.Permission
        }

        # Convert the Permission to an ACE.
        $ht = @{
            Identity    = Find-Identity @indentityParams
            Permissions = ConvertTo-ACETokenList @aceTokenParams
        }

        # If the Identity is not found, log a warning.
        if (-not $ht.Identity) {
            Write-Warning "[New-ACLToken] Identity $($Permission.Identity) was not found. This will not be added to the ACEs list."
            continue
        }
        # If the Permissions are not found, log a warning.
        if (-not $ht.Permissions) {
            Write-Warning "[New-ACLToken] Permissions for $($Permission.Identity) were not found. This will not be added to the ACEs list."
            continue
        }

        # Add the constructed ACE to the ACEs list.
        $ACEs.Add($ht)

    }

    return $ACEs

}
