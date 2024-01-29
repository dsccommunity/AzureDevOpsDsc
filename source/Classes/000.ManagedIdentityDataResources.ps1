data AzManagedIdentityLocalizedData {

    ConvertFrom-StringData @'
    Global_AzureDevOps_Resource_Id=499b84ac-1321-427f-aa17-267ca6975798
    Global_Url_Azure_Instance_Metadata_Url=http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource={0}
    Global_API_Azure_DevOps_Version=api-version=6.0
    Global_Url_AZDO_Project=https://dev.azure.com/{0}/_apis/projects
    Error_ManagedIdentity_RestApiCallFailed=Error. Failed to call the Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available. Error Details: {0}
    Error_Azure_Instance_Metadata_Service_Missing_Token=Error. Access token not returned from Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available.
    Error_Azure_API_Call_Generic=Error. Failed to call the Azure DevOps API. Details: {0}
    Error_Azure_Get_AzManagedIdentity_Invalid_Caller=Error. Get-AzManagedIdentity can only be called from New-AzManagedIdentity or Update-AzManagedIdentity.
'@

}

New-Variable -Name AzManagedIdentityLocalizedData -Value $AzManagedIdentityLocalizedData -Option ReadOnly -Scope Global -Force
