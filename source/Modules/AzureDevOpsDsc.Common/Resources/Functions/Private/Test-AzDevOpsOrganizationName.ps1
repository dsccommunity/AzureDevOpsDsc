<#
    .SYNOPSIS
        Peforms test on a provided 'OrganizationName' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER OrganizationName
        The 'OrganizationName' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'OrganizationName'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsOrganizationName -OrganizationName 'YourOrganizationNameHere' -IsValid

        Returns $true if the 'OrganizationName' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsOrganizationName
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $OrganizationName,

        [Parameter(Mandatory = $true)]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if ([System.String]::IsNullOrWhiteSpace($OrganizationName) -or
        ($OrganizationName.Contains(' ') -or $OrganizationName.Contains('%') -or $OrganizationName.Contains('*') -or $OrganizationName.StartsWith(' ') -or $OrganizationName.EndsWith(' ')))
    {
        return $false
    }

    return $true
}
