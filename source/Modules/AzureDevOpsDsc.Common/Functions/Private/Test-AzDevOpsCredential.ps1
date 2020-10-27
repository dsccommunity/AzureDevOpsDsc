<#
    .SYNOPSIS
        Peforms test on a provided 'Credential' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER Credential
        The 'Credential' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'Credential'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsCredential -Credential 'YourCredentialHere' -IsValid

        Returns $true if the 'Credential' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsCredential
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if (!$IsValid)
    {
        $errorMessage = $script:localizedData.MandatoryIsValidSwitchNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }

    # TODO:
    #  - Validate username is 'PAT' ?

    return $true
}
