<#
.SYNOPSIS
Formats a user principal name by combining a prefix and a group name.

.DESCRIPTION
The Format-AzDoGroup function takes a prefix and a group name as input parameters and returns a formatted user principal name. The user principal name is formatted as "[Prefix]\[GroupName]".

.PARAMETER Prefix
The prefix to be used in the user principal name.

.PARAMETER GroupName
The group name to be used in the user principal name.

.EXAMPLE
Format-AzDoGroup -Prefix "Contoso" -GroupName "Developers"
Returns: "[Contoso]\Developers"

#>

Function Format-AzDoGroup
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('ProjectName', 'Organization')]
        [string]
        $Prefix,

        [Parameter(Mandatory = $true)]
        [String]
        $GroupName
    )

    # If the prefix contains starting or ending square brackets, remove them.
    $Prefix = $Prefix -replace '^\[|\]$', ''

    # Build the User Principal Name string
    $userPrincipalName = '[{0}]\{1}' -f $Prefix, $GroupName

    # Use a verbose statement to show the input and resulting formatted UPN
    Write-Verbose "[Format-AzDoGroup] Formatting User Principal Name with Prefix: '$Prefix' and GroupName: '$GroupName'."
    Write-Verbose "[Format-AzDoGroup] Resulting User Principal Name: '$userPrincipalName'."

    return $userPrincipalName

}
