<#
.SYNOPSIS
Obtains a managed identity token from Azure AD.

.DESCRIPTION
The Get-AzManagedIdentityToken function is used to obtain an access token from Azure AD using a managed identity. It can only be called from the New-AzManagedIdentity or Update-AzManagedIdentity functions.

.PARAMETER OrganizationName
Specifies the name of the organization.

.PARAMETER Verify
Specifies whether to verify the connection. If this switch is not set, the function returns the managed identity token. If the switch is set, the function tests the connection and returns the access token.

.EXAMPLE
Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
Obtains the access token for the managed identity associated with the organization "Contoso" and verifies the connection.

.NOTES
This function requires the Azure PowerShell module.
#>
Function Get-AzManagedIdentityToken {
    [CmdletBinding()]
    param (
        # Organization Name
        [Parameter(Mandatory)]
        [String]
        $OrganizationName,

        # Verify the Connection
        [Parameter()]
        [Switch]
        $Verify
    )

    # Get-AzManagedIdentityToken can only be called from New-AzManagedIdentity or Update-AzManagedIdentity
    if ($MyInvocation.InvocationName -ne 'New-AzManagedIdentity' -and $MyInvocation.InvocationName -ne 'Update-AzManagedIdentity') {
        Throw "Get-AzManagedIdentityToken can only be called from New-AzManagedIdentity or Update-AzManagedIdentity"
    }

    # Obtain the access token from Azure AD using the Managed Identity

    $ManagedIdentityParams = @{
        # Define the Azure instance metadata endpoint to get the access token
        Uri = $LocalizedData.Global_Url_AzureInstanceMetadataUrl -f $LocalizedData.Global_AzureDevOps_Resource_Id
        Method = 'Get'
        Headers = @{Metadata="true"}
        'Context-Type' = 'Application/json'
    }

    # Invoke the RestAPI

    try {
        $response = Invoke-AzDevOpsApiRestMethod @params @ManagedIdentityParams
    } catch {
        Throw
    }

    $this.InvokeRestMethod($ManagedIdentityParams.Uri, $ManagedIdentityParams.Method, $ManagedIdentityParams.Headers)
    if ($null -eq $response.access_token) { throw $LocalizedData.Error_Azure_Instance_Metadata_Service_Missing_Token }

    # TypeCast the response to a ManagedIdentityToken object
    $ManagedIdentity = [ManagedIdentityToken]::New($response)
    # Null the response
    $null = $response

    # Return the token if the verify switch is not set
    if (-not($verify)) { return $ManagedIdentity }

    # Test the Connection
    if (-not(Test-AzManagedIdentityToken)) { throw $LocalizedData.Error_Azure_API_Call_Generic }

    # Return the AccessToken
    return ($ManagedIdentity)

}
