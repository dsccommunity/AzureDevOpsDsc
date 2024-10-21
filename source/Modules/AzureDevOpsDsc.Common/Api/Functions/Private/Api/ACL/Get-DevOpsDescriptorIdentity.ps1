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
Function Get-DevOpsDescriptorIdentity
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Descriptors')]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [String]$SubjectDescriptor,

        [Parameter(Mandatory = $true, ParameterSetName = 'Descriptors')]
        [String]$Descriptor,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Descriptors')]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    # Determine the query parameter based on the parameter set
    if ($SubjectDescriptor)
    {
        $query = "subjectDescriptors=$SubjectDescriptor"
    }
    else
    {
        $query = "descriptors=$Descriptor"
    }

    #
    # Construct the URL for the API call
    $params = @{
        Uri = 'https://vssps.dev.azure.com/{0}/_apis/identities?{1}&api-version={2}' -f $OrganizationName, $query, $ApiVersion
        Method = 'Get'
    }

    # Invoke the REST API call
    $identity = Invoke-AzDevOpsApiRestMethod @params

    if (($null -eq $identity.value) -or ($identity.count -gt 1))
    {
        return $null
    }

    return $identity.value

}
