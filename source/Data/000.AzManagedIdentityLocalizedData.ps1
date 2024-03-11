data AzManagedIdentityLocalizedData {

    ConvertFrom-StringData @'
    Error_ManagedIdentity_RestApiCallFailed=Error. Failed to call the Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available. Error Details: {0}
    Error_Azure_API_Call_Generic=Error. Failed to call the Azure DevOps API. Details: {0}
    Error_Azure_Get_AzManagedIdentity_Invalid_Caller=Error. Get-AzManagedIdentity can only be called from New-AzManagedIdentity or Update-AzManagedIdentity.
'@

}

New-Variable -Name AzManagedIdentityLocalizedData -Value $AzManagedIdentityLocalizedData -Option ReadOnly -Scope Global -Force
