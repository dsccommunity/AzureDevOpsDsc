<#
    .SYNOPSIS
        Peforms test on a provided '(Pat)Credential' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER PatCredential
        The '(Pat)Credential' containing the Personal Access Token (PAT) to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the '(Pat)Credential'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsCredential -PatCredential $YourPatCredentialHere$ -IsValid

        Returns $true if the '(Pat)Credential' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsPatCredential
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [Alias('Credential')]
        $PatCredential,

        [Parameter(Mandatory = $true)]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    return !($null -eq $PatCredential -or
             'PAT' -ne $PatCredential.UserName)
}
