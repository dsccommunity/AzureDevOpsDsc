<#
.SYNOPSIS
Retrieves the identity associated with a given subject descriptor in Azure DevOps.

.DESCRIPTION
The Get-DevOpsDescriptorIdentity function retrieves the identity associated with a given subject descriptor in Azure DevOps. It makes a REST API call to the Azure DevOps API to fetch the identity information.

.PARAMETER OrganizationName
The name of the Azure DevOps organization.

.PARAMETER SubjectDescriptor
The subject descriptor of the identity to retrieve.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default API version will be used.

.EXAMPLE
Get-DevOpsDescriptorIdentity -OrganizationName "MyOrg" -SubjectDescriptor "subject:abcd1234"

This example retrieves the identity associated with the subject descriptor "subject:abcd1234" in the Azure DevOps organization "MyOrg".

#>
Function Get-DevOpsDescriptorIdentity {

    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [String]$SubjectDescriptor,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )


    #
    # Construct the URL for the API call
    $params = @{
        Uri = "https://vssps.dev.azure.com/{0}/_apis/identities?subjectDescriptors={1}&api-version={2}" -f $OrganizationName, $SubjectDescriptor, $ApiVersion
        Method = 'Get'
    }

    # Invoke the REST API call
    $identity = Invoke-AzDevOpsApiRestMethod @params

    if (($null -eq $identity.value) -or ($identity.count -gt 1)) {
        return $null
    }

    return $identity.value

}
