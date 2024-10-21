<#
.SYNOPSIS
Sets the Personal Access Token (PAT) for an Azure DevOps organization.

.DESCRIPTION
The Set-AzPersonalAccessToken function sets the Personal Access Token (PAT) for an Azure DevOps organization.
It supports both plain text and secure string PATs. Optionally, it can verify the connection to the Azure DevOps API.

.PARAMETER OrganizationName
Specifies the name of the Azure DevOps organization.

.PARAMETER PersonalAccessToken
Specifies the Personal Access Token (PAT) in plain text.

.PARAMETER SecureStringPersonalAccessToken
Specifies the Personal Access Token (PAT) as a secure string.

.PARAMETER Verify
Indicates that the connection to the Azure DevOps API should be verified.

.EXAMPLE
Set-AzPersonalAccessToken -OrganizationName "MyOrg" -PersonalAccessToken "myPAT"

Sets the PAT for the organization "MyOrg" using the provided plain text PAT.

.EXAMPLE
Set-AzPersonalAccessToken -OrganizationName "MyOrg" -SecureStringPersonalAccessToken $securePAT

Sets the PAT for the organization "MyOrg" using the provided secure string PAT.

.EXAMPLE
Set-AzPersonalAccessToken -OrganizationName "MyOrg" -PersonalAccessToken "myPAT" -Verify

Sets the PAT for the organization "MyOrg" and verifies the connection to the Azure DevOps API.

.NOTES
This function requires the New-PersonalAccessToken and Test-AzToken functions to be defined.
#>
Function Set-AzPersonalAccessToken
{
    [CmdletBinding(DefaultParameterSetName = 'PersonalAccessToken')]
    param (
        # Organization Name
        [Parameter(Mandatory = $true, ParameterSetName = 'PersonalAccessToken')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Alias('OrgName')]
        [String]
        $OrganizationName,

        # Personal Access Token
        [Parameter(Mandatory = $true, ParameterSetName = 'PersonalAccessToken')]
        [Alias("PAT")]
        [String]
        $PersonalAccessToken,

        # Secure String Personal Access Token
        [Parameter(Mandatory = $true, ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Alias("SecureStringPAT")]
        [SecureString]
        $SecureStringPersonalAccessToken,

        # Verify the Connection
        [Parameter(ParameterSetName = 'SecureStringPersonalAccessToken')]
        [Parameter(ParameterSetName = 'PersonalAccessToken')]
        [Switch]
        $Verify
    )

    Write-Verbose "[Set-PersonalAccessToken] Setting the Personal Access Token for the organization $OrganizationName."

    # If a SecureString Personal Access Token is provided, parse it and set as the Token
    if ($SecureStringPersonalAccessToken)
    {
        $Token = New-PersonalAccessToken -SecureStringPersonalAccessToken $SecureStringPersonalAccessToken
    }
    elseif ($PersonalAccessToken)
    {
        # TypeCast the response to a PersonalAccessToken object
        $Token = New-PersonalAccessToken -PersonalAccessToken $PersonalAccessToken
    }
    else
    {
        throw "Error. A Personal Access Token or SecureString Personal Access Token must be provided."
    }

    #
    # Return the token if the verify switch is not set
    if (-not($verify))
    {
        return $Token
    }

    Write-Verbose "[Set-PersonalAccessToken] Verifying the connection to the Azure DevOps API."

    # Test the Connection
    if (-not(Test-AzToken $Token))
    {
        throw "Error. Failed to call the Azure DevOps API."
    }

    Write-Verbose "[Set-PersonalAccessToken] Connection Verified."

    # Return the AccessToken
    return ($Token)

}
