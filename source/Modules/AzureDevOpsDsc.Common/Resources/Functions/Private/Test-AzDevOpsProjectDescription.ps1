<#
    .SYNOPSIS
        Peforms test on a provided 'ProjectDescription' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER ProjectDescription
        The 'ProjectDescription' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'ProjectDescription'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsProjectDescription -ProjectDescription 'YourProjectDescriptionHere' -IsValid

        Returns $true if the 'ProjectDescription' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsProjectDescription
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $ProjectDescription,

        [Parameter(Mandatory = $true)]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    return !($ProjectDescription -eq $null -or
             ($ProjectDescription.Contains('%') -or
              $ProjectDescription.Contains('*') -or
              $ProjectDescription.StartsWith(' ') -or
              $ProjectDescription.EndsWith(' ')))
}
