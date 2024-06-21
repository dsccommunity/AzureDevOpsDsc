<#
.SYNOPSIS
    Finds an identity (user or group) based on the provided name.

.DESCRIPTION
    The Find-Identity function searches for an identity (user or group) based on the provided name. It first checks the cached groups and users to find a match. If multiple identities with the same name are found, a warning is issued and null is returned.

.PARAMETER Name
    The name of the identity to search for.

.OUTPUTS
    Returns the ACLIdentity object of the found identity. If no identity is found, null is returned.

.NOTES
    Author: Your Name
    Date:   Current Date

.EXAMPLE
    Find-Identity -Name "JohnDoe"
    Returns the ACLIdentity object of the identity with the name "JohnDoe" if found. Otherwise, returns null.

#>

Function Find-Identity {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    # Logging
    Write-Verbose "[Find-Identity] Started."

    $CachedGroups = Get-CacheObject -CacheType 'LiveGroups'
    $CachedUsers = Get-CacheObject -CacheType 'LiveUsers'

    $groupIdentity = $CachedGroups | Where-Object { $_.value.ACLIdentity.descriptor -eq $Name }
    $userIdentity = $CachedUsers | Where-Object { $_.value.ACLIdentity.descriptor -eq $Name }

    # Check if multiple identities were found.
    # While this is not a common scenario, there is a possibility that a user and a group have the same name.
    if ($groupIdentity -and $userIdentity) {
        Write-Warning "[Find-Identity] Found multiple identities with the name '$Name'. Returning null."
        return $null
    }

    # If the group identity was found, return the ACLIdentity.
    # If the user identity was found, return the ACLIdentity.

    if ($groupIdentity) {
        Write-Verbose "[Find-Identity] Found group identity for '$Name'."
        return $groupIdentity.value.ACLIdentity
    } elseif ($userIdentity) {
        Write-Verbose "[Find-Identity] Found group identity for '$Name'."
        return $userIdentity.value.ACLIdentity
    }

    # Return null if no identity was found
    return $null

}