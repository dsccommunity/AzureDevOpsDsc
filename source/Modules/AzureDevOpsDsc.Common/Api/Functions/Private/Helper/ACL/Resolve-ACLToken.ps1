<#
.SYNOPSIS
    Resolves the ACL token from the provided reference or difference ACL objects.

.DESCRIPTION
    The Resolve-ACLToken function returns the token from the provided ACL objects.
    It prefers the token from the DifferenceObject if it is not null, as it contains
    the most recent information. If the DifferenceObject is null, it returns the token
    from the ReferenceObject.

.PARAMETER ReferenceObject
    The reference ACL object(s) from which the token can be resolved if the DifferenceObject is null.

.PARAMETER DifferenceObject
    The difference ACL object(s) from which the token is preferred if it is not null.

.EXAMPLE
    $referenceACL = @{}
    $differenceACL = @{}
    $token = Resolve-ACLToken -ReferenceObject $referenceACL -DifferenceObject $differenceACL

.NOTES
    This function is part of the AzureDevOpsDsc module.
#>
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
