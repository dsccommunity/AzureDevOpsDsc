<#
.SYNOPSIS
    Finds an identity (user or group) based on the provided name.

.DESCRIPTION
    The Find-Identity function searches for an identity (user or group) based on the provided name.
    It first checks the cached groups and users to find a match.
    If multiple identities with the same name are found, a warning is issued and null is returned.

.PARAMETER Name
    The name of the identity to search for.

.PARAMETER OrganizationName
    The name of the organization.

.PARAMETER SearchType
    The type of search to perform. Valid values are 'descriptor', 'descriptorId', 'displayName', 'originId', 'key'.

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
    [CmdletBinding()]
    param(
        # The name of the identity to search for.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # The name of the organization.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OrganizationName,

        # The type of search to perform.
        [Parameter()]
        [ValidateSet('descriptor', 'descriptorId', 'displayName', 'originId', 'principalName')]
        [string]$SearchType = 'descriptor'
    )

    # Logging
    Write-Verbose "[Find-Identity] Started."
    Write-Verbose "[Find-Identity] Name: $Name"
    Write-Verbose "[Find-Identity] Organization Name: $OrganizationName"
    Write-Verbose "[Find-Identity] Search Type: $SearchType"

    try {
        $CachedGroups = Get-CacheObject -CacheType 'LiveGroups'
        $CachedUsers = Get-CacheObject -CacheType 'LiveUsers'
        $CachedServicePrincipals = Get-CacheObject -CacheType 'LiveServicePrinciples'
    } catch {
        Write-Error "Failed to retrieve cache objects: $_"
        return $null
    }

    #
    # Define the lookup table based on the search type

    switch ($SearchType) {
        'descriptor' {
            $lookup = @{
                groupIdentitySB             = { $_.value.ACLIdentity.descriptor -eq $Name }
                userIdentitySB              = { $_.value.ACLIdentity.descriptor -eq $Name }
                servicePrincipalIdentitySB  = { $_.value.ACLIdentity.descriptor -eq $Name }
            }
        }
        'descriptorId' {
            $lookup = @{
                groupIdentitySB             = { $_.value.ACLIdentity.id -eq $Name }
                userIdentitySB              = { $_.value.ACLIdentity.id -eq $Name }
                servicePrincipalIdentitySB  = { $_.value.ACLIdentity.id -eq $Name }
            }
        }
        'originId' {
            $lookup = @{
                groupIdentitySB             = { $_.value.originId -eq $Name }
                userIdentitySB              = { $_.value.originId -eq $Name }
                servicePrincipalIdentitySB  = { $_.value.originId -eq $Name }
            }
        }
        'principalName' {
            $lookup = @{
                groupIdentitySB             = { $_.value.principalName.replace('[','').replace(']','') -eq $Name }
                userIdentitySB              = { $_.value.principalName -eq $Name }
                servicePrincipalIdentitySB  = { $_.value.principalName -eq $Name }
            }
        }
        'displayName' {
            $lookup = @{
                groupIdentitySB             = { $_.value.displayName -eq $Name }
                userIdentitySB              = { $_.value.displayName -eq $Name }
                servicePrincipalIdentitySB  = { $_.value.displayName -eq $Name }
            }
        }
        default {
            Write-Error "Invalid SearchType: $SearchType"
            return $null
        }
    }

    #
    # Find the identity

    $groupIdentity = $CachedGroups | Where-Object $lookup.groupIdentitySB
    $userIdentity = $CachedUsers | Where-Object $lookup.userIdentitySB
    $servicePrincipalIdentity = $CachedServicePrincipals | Where-Object $lookup.servicePrincipalIdentitySB

    # Check if multiple identities were found.
    if ($groupIdentity -or $userIdentity -or $servicePrincipalIdentity) {
        if (($groupIdentity -and $userIdentity) -or ($groupIdentity -and $servicePrincipalIdentity) -or ($userIdentity -and $servicePrincipalIdentity)) {
            Write-Warning "[Find-Identity] Found multiple identities with the name '$Name'. Returning null."
            return $null
        }

        if ($groupIdentity) {
            Write-Verbose "[Find-Identity] Found group identity for '$Name'."
            Write-Verbose "[Find-Identity] $SearchType"
            return $groupIdentity
        } elseif ($userIdentity) {
            Write-Verbose "[Find-Identity] Found user identity for '$Name'."
            return $userIdentity
        } elseif ($servicePrincipalIdentity) {
            Write-Verbose "[Find-Identity] Found service principal identity for '$Name'."
            return $servicePrincipalIdentity
        }
    } else {
        Write-Warning "[Find-Identity] No identity found for '$Name'. Performing a lookup via the API."

        # Perform a lookup via the API
        $params = @{
            OrganizationName = $OrganizationName
            Descriptor = $Name
        }

        Write-Verbose "[Find-Identity] Performing a lookup via the API."
        Write-Verbose "[Find-Identity] $SearchType"

        try {
            # Get the identity
            $identity = Get-DevOpsDescriptorIdentity @params
        } catch {
            Write-Error "Failed to retrieve identity via API: $_"
            return $null
        }

        # Attempt to match the identity using the ID
        $groupIdentity = $CachedGroups | Where-Object { $_.value.ACLIdentity.id -eq $identity.id }
        $userIdentity = $CachedUsers | Where-Object { $_.value.ACLIdentity.id -eq $identity.id }
        $servicePrincipalIdentity = $CachedServicePrincipals | Where-Object { $_.value.ACLIdentity.id -eq $identity.id }

        # Test if the identity was found
        if ($groupIdentity -or $userIdentity -or $servicePrincipalIdentity) {

            # Check if multiple identities were found.
            if (($groupIdentity -and $userIdentity) -or ($groupIdentity -and $servicePrincipalIdentity) -or ($userIdentity -and $servicePrincipalIdentity)) {
                Write-Warning "[Find-Identity] Found multiple identities with the ID '$($identity.id)'. Returning null."
                return $null
            }

            if ($groupIdentity) {
                Write-Verbose "[Find-Identity] Found group identity for '$Name'."
                return $groupIdentity
            } elseif ($userIdentity) {
                Write-Verbose "[Find-Identity] Found user identity for '$Name'."
                return $userIdentity
            } elseif ($servicePrincipalIdentity) {
                Write-Verbose "[Find-Identity] Found service principal identity for '$Name'."
                return $servicePrincipalIdentity
            }
        }

        # If no identity was found, write a warning and return null
        Write-Warning "[Find-Identity] No identity found for '$Name'."
        return $null

    }

    # Return null if no identity was found
    return $null
}
