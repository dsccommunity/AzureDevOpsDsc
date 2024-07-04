
# The Azure Devops ACL API is different to other ACL APIs where it only provides a means to get, remove and set ACLs.
# This means that if there is a change to the ACL's then the entire ACL must be set again.
# This function captures the differences between two ACLs and if there is a different the properties changed will contain the new reference ACL.
#

Function Test-ACLListforChanges
{
    [CmdletBinding()]
    param (
        # The Reference ACL to compare against.
        [Parameter()]
        [Object[]]
        $ReferenceACLs,

        # The Difference ACL to compare against.
        [Parameter()]
        [Object[]]
        $DifferenceACLs
    )

    Write-Verbose "[Test-ACLListforChanges] Started."

    $result = @{
        status = "Unchanged"
        propertiesChanged = @()
    }

    $ReferenceACLs | Export-CLixml C:\Temp\Ref.clixml
    $DifferenceACLs | Export-CLixml C:\Temp\Diff.clixml

    #
    # Test if the Reference and Difference ACLs are null.

    if ($ReferenceACLs -eq $null -and $DifferenceACLs -eq $null)
    {
        Write-Verbose "[Test-ACLListforChanges] ACLs are null."
        return $result.propertiesChanged
    }

    # Get the Token
    #$Token = Get-ACLToken $ReferenceACLs $DifferenceACLs

    # If the Reference ACL is null, set the status to changed.
    if ($null -eq $ReferenceACLs)
    {
        Write-Verbose "[Test-ACLListforChanges] Reference ACL is null."
        $result.status = "Missing"
        $result.propertiesChanged = $DifferenceACLs
        return $result
    }

    # If the Difference ACL is null, set the status to changed.
    if ($null -eq $DifferenceACLs)
    {
        Write-Verbose "[Test-ACLListforChanges] Difference ACL is null."
        $result.status = "NotFound"
        $result.propertiesChanged = $ReferenceACLs
        return $result
    }

    # Set the flag to be false
    $isChanged = $false

    #
    # Test if the Reference and Difference ACLs count is not equal.

    if ($ReferenceACLs.ACEs.Count -ne $DifferenceACLs.ACEs.Count)
    {
        Write-Verbose "[Test-ACLListforChanges] ACLs count is not equal."
        $result.status = "Changed"
        $result.propertiesChanged = $ReferenceACLs
        return $result
    }

    #
    # Test each of the ACLs

    ForEach ($ReferenceACL in $ReferenceACLs) {

        $acl = $DifferenceACLs | Where-Object { $_.Identity.value.originId -eq $ReferenceACL.Identity.value.originId }

        # Test if the ACL is not found in the Difference ACL.
        if ($null -eq $acl) {
            $result.status = "Changed"
            $result.propertiesChanged = $ReferenceACLs
            return $result
        }

        # Test the inherited flag.
        if ($ReferenceACL.isInherited -ne $acl.isInherited) {
            $result.status = "Changed"
            $result.propertiesChanged = $ReferenceACLs
            return $result
        }

        # Iterate through the ACEs and compare them.

        ForEach ($ReferenceACE in $ReferenceACL.ACEs) {

            # Check if the ACE is found in the Difference ACL.
            $ace = $DifferenceACLs.ACEs | Where-Object { $_.Identity.value.originId -eq $ReferenceACE.ACEs.Identity.value.originId }

            # Check if the ACE is not found in the Difference ACL.
            if ($null -eq $ace) {
                $result.status = "Changed"
                $result.propertiesChanged = $ReferenceACLs
                return $result
            }

            #
            # From this point on, we know that the ACE is found in both ACLs.

            #
            # Compare the Allow ACEs

            $ReferenceAllow = Get-BitwiseOrResult $ReferenceACE.Permissions.Allow.Bit
            $DifferenceACLs = Get-BitwiseOrResult $ace.Permissions.Allow.Bit

            # Test if the integers are not equal.
            if ($ReferenceAllow -ne $DifferenceAllow)
            {
                Write-Verbose "[Test-ACLListforChanges] Allow ACEs are not equal."
                $result.propertiesChanged = $ReferenceACLs
                $result.status = "Changed"
            }

            #
            # Compare the Deny ACEs

            $ReferenceDeny = Get-BitwiseOrResult $ReferenceACE.Permissions.Deny.Bit
            $DifferenceDeny = Get-BitwiseOrResult $ace.Permissions.Deny.Bit

            # Test if the integers are not equal.
            if ($ReferenceDeny -ne $DifferenceDeny)
            {
                Write-Verbose "[Test-ACLListforChanges] Deny ACEs are not equal."
                $result.propertiesChanged = $ReferenceACLs
                $result.status = "Changed"
            }

        }

    }

    #
    # Test each of the Difference ACLs

    foreach ($DifferenceACL in $DifferenceACLs) {

        $acl = $ReferenceACLs | Where-Object { $_.Identity.value.originId -eq $DifferenceACL.Identity.value.originId }

        # Test if the ACL is not found in the Reference ACL.
        if ($null -eq $acl) {
            $result.status = "Changed"
            $result.propertiesChanged = $ReferenceACLs
            return $result
        }

        # No other tests are required as the Reference ACL has already been tested.

    }

    # Result the result hash table.
    return $result

}
