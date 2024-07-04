function Resolve-ACLToken
{
    param (
        # Reference ACL
        [Parameter()]
        [Object[]]
        $ReferenceObject,

        # Difference ACL
        [Parameter()]
        [Object[]]
        $DifferenceObject
    )

    Write-Verbose "[Resolve-ACLToken] Started."

    # Prefer the Difference ACL if it is not null. This is because the Difference ACL contains the most recent information.
    if ($null -ne $DifferenceObject)
    {
        Write-Verbose "[Resolve-ACLToken] Difference ACL is not null."
        return $DifferenceObject.token._token
    }

    Write-Verbose "[Resolve-ACLToken] Difference ACL is null."
    return $ReferenceObject.token._token
}
