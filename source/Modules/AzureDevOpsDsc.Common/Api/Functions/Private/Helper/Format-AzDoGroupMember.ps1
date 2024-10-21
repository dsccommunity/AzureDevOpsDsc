<#
.SYNOPSIS
Formats an Azure DevOps group member name by removing square brackets and reformatting the string.

.PARAMETER GroupName
The name of the group to be formatted. This parameter is mandatory.

.RETURNS
System.String
A formatted string representing the group name in the format '[prefix]\group'.

.EXAMPLE
$formattedName = Format-AzDoGroupMember -GroupName '[prefix]\group'
# This will return 'prefix\group'.

#>
Function Format-AzDoGroupMember
{
    param(
        [Parameter(Mandatory = $true)]
        [System.String]$GroupName
    )

    # If the group name contains starting or ending square brackets, remove them.
    $GroupName = $GroupName -replace '^\[|\]', ''

    # Build the GroupName string

    # Split the GroupName into the prefix and the group name.
    $prefix, $group = $GroupName -split '\\'

    return '[{0}]\{1}' -f $prefix, $group

}
