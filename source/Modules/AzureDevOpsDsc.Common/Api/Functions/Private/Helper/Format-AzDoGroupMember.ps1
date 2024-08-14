Function Format-AzDoGroupMember
{
    param(
        [Parameter(Mandatory)]
        [System.String]$GroupName
    )

    # If the group name contains starting or ending square brackets, remove them.
    $GroupName = $GroupName -replace '^\[|\]', ''

    # Build the GroupName string

    # Split the GroupName into the prefix and the group name.
    $prefix, $group = $GroupName -split '\\'

    return "[{0}]\{1}" -f $prefix, $group

}
