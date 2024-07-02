Function Compare-ACLs
{
    [CmdletBinding()]
    param (
        # The Reference ACL to compare against.
        [Parameter()]
        [Object[]]
        $ReferenceObject,

        # The Difference ACL to compare against.
        [Parameter()]
        [Object[]]
        $DifferenceObject
    )

    Write-Verbose "[Compare-ACLs] Started."

    $result = @{
        status = "Unchanged"
        propertiesChanged = @()
    }

    #
    # Test if the Reference and Difference ACLs are null.

    if ($ReferenceObject -eq $null -and $DifferenceObject -eq $null)
    {
        Write-Verbose "[Compare-ACLs] ACLs are null."
        return $result.propertiesChanged
    }

    # If the Reference ACL is null, set the status to changed.
    if ($null -eq $ReferenceObject)
    {
        Write-Verbose "[Compare-ACLs] Reference ACL is null."
        $result.propertiesChanged += @{
            Name = 'ReferenceACL'
            ReferenceObject = $null
            DifferenceObject = $DifferenceObject
        }
        $result.status = "Missing"
        return $result
    }

    # If the Difference ACL is null, set the status to changed.
    if ($null -eq $DifferenceObject)
    {
        Write-Verbose "[Compare-ACLs] Difference ACL is null."
        $result.propertiesChanged += @{
            Name = 'DifferenceACL'
            ReferenceObject = $ReferenceObject
            DifferenceObject = $null
        }
        $result.status = "NotFound"
        return $result
    }

    #
    # Test inheritance

    # Check if the Reference ACL and Difference ACL are inherited.
    if ($ReferenceObject.isInherited -ne $DifferenceObject.isInherited)
    {
        Write-Verbose "[Compare-ACLs] ACLs are not inherited."
        $result.propertiesChanged += @{
            Name = 'isInherited'
            ReferenceObject = $ReferenceObject
            DifferenceObject = $DifferenceObject
        }
        # Set the status to changed.
        $result.status = "Changed"
    }

    #
    # Test ACES

    # Check if the ACLs are not found.
    ForEach ($ReferenceACE in $ReferenceObject.ACEs)
    {

        # Check if the ACE is found in the Difference ACL.
        $identity = $DifferenceObject.ACEs | Where-Object { $_.Identity.value.originId -eq $ReferenceACE.Identity.value.originId }

        #
        # Check if the ACE is not found in the Difference ACL.

        if (-not $identity) {
            Write-Verbose "[Compare-ACLs] ACE not found in Difference ACL."
            $result.propertiesChanged += @{
                Name = 'ACE'
                ReferenceObject = $ReferenceObject
                DifferenceObject = $DifferenceObject
                ReferenceACE = $ReferenceACE
                DifferenceACE = $null
            }
            # Set the status to changed.
            $result.status = "Changed"

            # Continue to the next ACE.
            continue
        }

        #
        # From this point on, we know that the ACE is found in both ACLs.

        #
        # Compare the Allow ACEs

        $ReferenceAllow = BorArray $ReferenceACE.Permissions.Allow.Bit
        $DifferenceObject = BorArray $identity.Permissions.Allow.Bit

        # Test if the integers are not equal.
        if ($ReferenceAllow -ne $DifferenceAllow)
        {
            Write-Verbose "[Compare-ACLs] Allow ACEs are not equal."
            $result.propertiesChanged += @{
                Name = 'ACEAllow'
                Identity = $ReferenceACE.Identity
                ReferenceObject = $ReferenceAllow
                DifferenceObject = $DifferenceAllow
            }
            # Set the status to changed.
            $result.status = "Changed"
        }

        # Compare the Deny ACEs

        $ReferenceDeny = BorArray $ReferenceACE.Permissions.Deny.Bit
        $DifferenceDeny = BorArray $identity.Permissions.Deny.Bit

        # Test if the integers are not equal.
        if ($ReferenceDeny -ne $DifferenceDeny)
        {
            Write-Verbose "[Compare-ACLs] Deny ACEs are not equal."
            $result.propertiesChanged += @{
                Name = 'ACEDeny'
                Identity = $ReferenceACE.Identity
                ReferenceObject = $ReferenceDeny
                DifferenceObject = $DifferenceDeny
            }
            # Set the status to changed.
            $result.status = "Changed"
        }

    }

    # Check if the ACE is found in the Difference ACL.
    ForEach ($DifferenceACE in $DifferenceObject.ACEs) {

        # Check if the ACE is found in the Reference ACL.
        $identity = $ReferenceObject.ACEs | Where-Object { $_.Identity.value.originId -eq $DifferenceACE.Identity.value.originId }

        # Check if the ACE is not found in the Reference ACL.
        if (-not $identity) {
            Write-Verbose "[Compare-ACLs] ACE not found in Reference ACL."
            $result.propertiesChanged += @{
                Name = 'ACE'
                ReferenceObject = $null
                DifferenceObject = $DifferenceACE
            }
            # Set the status to changed.
            $result.status = "Changed"
            # Continue to the next ACE.
            continue
        }

        # No additional checks are needed as the ACE is already compared.

    }

    # Result the result hash table.
    return $result

}
