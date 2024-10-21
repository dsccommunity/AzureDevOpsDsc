<#
.SYNOPSIS
    Finds an Azure DevOps identity (user or group) based on the provided identity string.

.DESCRIPTION
    The Find-AzDoIdentity function searches for an Azure DevOps identity (user or group) using the provided identity string.
    The identity string can be an email address, a group name, or a display name. The function first checks if the identity
    is an email address or a group name and performs the lookup accordingly. If the identity is neither, it performs a lookup
    using the display name.

.PARAMETER Identity
    The identity string to search for. This can be an email address, a group name, or a display name.

.EXAMPLE
    PS> Find-AzDoIdentity -Identity "user@domain.com"
    Finds the user with the specified email address.

.EXAMPLE
    PS> Find-AzDoIdentity -Identity "Project\GroupName"
    Finds the group with the specified name.

.EXAMPLE
    PS> Find-AzDoIdentity -Identity "Display Name"
    Finds the user or group with the specified display name.

.NOTES
    The function uses cached user and group data stored in the global variables $Global:AZDOLiveUsers and $Global:AZDOLiveGroups.
    If multiple users or groups are found with the same display name, a warning is issued and no result is returned.
    If both a user and a group are found with the same display name, a warning is issued and no result is returned.

#>
Function Find-AzDoIdentity
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$Identity
    )

    Write-Verbose "[Find-AzDoIdentity] Starting identity lookup for '$Identity'."

    # Get the Usernames from the cache
    $CachedUsers = $Global:AZDOLiveUsers
    Write-Verbose "[Find-AzDoIdentity] Retrieved cached users."

    # Get the Groups from the Cache
    $CachedGroups = $Global:AZDOLiveGroups
    Write-Verbose "[Find-AzDoIdentity] Retrieved cached groups."

    switch ($Identity)
    {

        # Test if the Username contains an '@' symbol. If it does, it is an email address and should be converted to a UPN
        { $Identity -like '*@*' } {
            Write-Verbose "[Find-AzDoIdentity] Identity is an email address; converting to UPN."

            # Perform a lookup using the existing username
            $cachedItem = Get-CacheItem -Key $Identity -Type 'LiveUsers'
            #$cachedItem = $cachedItem | Select-Object *, @{Name = 'Type'; Exp={'Users'}}

            # Test if the user is found
            if ($null -eq $cachedItem)
            {
                Write-Warning "[Find-AzDoIdentity] No user found with the UPN '$Identity'."
                return
            }

            Write-Verbose "[Find-AzDoIdentity] Found user with UPN '$Identity'."
            return $cachedItem
        }

        # Test if the Username contains a '\' or '/' symbol. If it does, it is a group and needs to be sanitized
        { $Identity -match '\\|\/' } {
            Write-Verbose "[Find-AzDoIdentity] Identity contains a '\' or '/'; treated as a group."

            # If the Identity 'Project\GroupName' does not contain square brackets, add them around the Project.
            if ($Identity -notmatch '\[.*\]')
            {
                $split = $Identity -split ('\\|\/')
                $Identity = '[{0}]\{1}' -f $split[0], $split[1]
            }

            # Perform a lookup using the existing username
            Write-Verbose "[Find-AzDoIdentity] Performing a lookup using the group name '$Identity'."
            $cachedItem = Get-CacheItem -Key $Identity -Type 'LiveGroups'

            # Test if the group is found
            if ($null -eq $cachedItem)
            {
                Write-Warning "[Find-AzDoIdentity] No group found with the name '$Identity'."
                return
            }

            #$cachedItem = $cachedItem | Select-Object *, @{Name = 'Type'; Exp={'Group'}}

            Write-Verbose "[Find-AzDoIdentity] cachedItem '$($cachedItem | ConvertTo-Json)'."
            Write-Verbose "[Find-AzDoIdentity] Found group with name '$Identity'."

            return $cachedItem
        }

        # If all else fails, try and perform a lookup using the display name.
        # If multiple users are found, throw an error.
        # If no users are found, throw an error.
        default {

            Write-Verbose "[Find-AzDoIdentity] Performing a lookup using the display name '$Identity'."

            # Perform a lookup using the existing username
            [Array]$User = $CachedUsers | Where-Object { $_.value.displayName -eq $Identity }
            [Array]$Group = $CachedGroups | Where-Object { $_.value.displayName -eq $Identity }

            # Write the number of users and groups found
            Write-Verbose "[Find-AzDoIdentity] Found $($User.Count) users and $($Group.Count) groups with the display name '$Identity'."

            # Test if the user is found
            if ($User.Count -gt 1)
            {
                Write-Warning "[Find-AzDoIdentity] Multiple users found with the display name '$Identity'. Please use the UPN (user@domain.com)"
                return
            }

            # Test if a group is found
            if ($Group.Count -gt 1)
            {
                Write-Warning "[Find-AzDoIdentity] Multiple groups found with the display name '$Identity'. Please use the UPN ([project]\[groupname])"
                return
            }

            # Test if both a user and a group are found
            if ($User.Count -eq 1 -and $Group.Count -eq 1)
            {
                Write-Warning "[Find-AzDoIdentity] Both a user and a group found with the display name '$Identity'. Please use the UPN (user@domain.com or [project]\[groupname])"
                return
            }

            if ($User.Count -eq 1)
            {
                # If the user is found, add the type and return the user
                Write-Verbose "[Find-AzDoIdentity] Single user found with the display name '$Identity'."
                return $User.value
            }
            elseif ($Group.Count -eq 1)
            {
                # If the group is found, add the type and return the group
                Write-Verbose "[Find-AzDoIdentity] Single group found with the display name '$Identity'."
                return $Group.value
            }

            Write-Warning "No identity found for '$Identity'."
            return

        }
    }
}
