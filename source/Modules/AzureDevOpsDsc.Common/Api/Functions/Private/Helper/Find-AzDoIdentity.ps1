

Function Find-AzDoIdentity {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$Identity
    )

    # Get the Usernames from the cache
    $CachedUsers = Get-CacheObject -CacheType 'LiveUsers'
    # Get the Groups from the Cache
    $CachedGroups = Get-CacheObject -CacheType 'LiveGroups'

    switch ($Identity) {

        # Test if the Username contains an '@' symbol. If it does, it is an email address and should be converted to a UPN
        { $Identity -like '*@*' } {
            # Perform a lookup using the existing username
            $cachedItem = Get-CacheItem -Key $Identity -Type 'LiveUsers'
            $cachedItem.value.add('Type','User')

            return $cachedItem
        }
        # Test if the Username contains a '\' or '/' symbol. If it does, it is a group and needs to be sanitized
        { $Identity -match '\\|\/') } {
            # Perform a lookup using the existing username
            $cachedItem = Get-CacheItem -Key $Identity -Type 'LiveGroups'
            $cachedItem.value.add('Type','Group')

            return $cachedItem
        }
        # If all else fails, try and perform a lookup using the display name.
        # If multiple users are found, throw an error.
        # If no users are found, throw an error.
        default {

            # Perform a lookup using the existing username
            $User = $CachedUsers | Where-Object { $_.value.displayName -eq $Identity }
            $Group = $CachedGroups | Where-Object { $_.value.displayName -eq $Identity }

            # Test if the user is found
            if ($User.Count -gt 1) {
                throw "Multiple users found with the display name '$Identity'. Please use the UPN (user@domain.com)"
            } elseif ($User.Count -eq 0) {
                throw "No users found with the display name '$Identity'. Please use the UPN (user@domain.com)"
            }

            # Test if a group is found
            if ($Group.Count -gt 1) {
                throw "Multiple groups found with the display name '$Identity'. Please use the UPN ([project]\[groupname])"
            } elseif ($Group.Count -eq 0) {
                throw "No groups found with the display name '$Identity'. Please use the UPN ([project]\[groupname])"
            }

            # Test if both a user and a group are found
            if ($User.Count -eq 1 -and $Group.Count -eq 1) {
                throw "Both a user and a group found with the display name '$Identity'. Please use the UPN (user@domain.com or [project]\[groupname])"
            }

            if ($User.Count -eq 1) {
                # If the user is found, add the type and return the user
                $User.Value.Add('Type','User')
                return $User
            } else {
                # If the group is found, add the type and return the group
                $User.Value.Add('Type','Group')
                return $Group
            }

        }

    }


}
