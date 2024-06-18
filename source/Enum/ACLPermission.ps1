<#
.SYNOPSIS
    Represents the permissions for an Access Control List (ACL).

.DESCRIPTION
    The ACLPermission enum defines the different permissions that can be assigned to an ACL.

    - Allow: Grants permission to perform the specified action.
    - AllowInherited: Grants permission to perform the specified action, inherited from a parent object.
    - Deny: Denies permission to perform the specified action.
    - DenyInherited: Denies permission to perform the specified action, inherited from a parent object.

.NOTES
    This enum is used in the context of Azure DevOps DSC.

#>
enum ACLPermission
{
    Allow = 1
    AllowInherited = 2
    Deny = 4
    DenyInherited = 8
}
