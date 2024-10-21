<#
.SYNOPSIS
Creates a new group in Azure DevOps.

.DESCRIPTION
The New-DevOpsGroup function creates a new group in Azure DevOps using the specified parameters.

.PARAMETER ApiUri
The URI of the Azure DevOps API.

.PARAMETER GroupName
The name of the group to create.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default version will be used.

.PARAMETER ProjectScopeDescriptor
The scope descriptor of the project. If specified, the group will be created within the specified project scope.

.OUTPUTS
System.Management.Automation.PSObject

.EXAMPLE
New-DevOpsGroup -ApiUri "https://dev.azure.com/myorganization" -GroupName "MyGroup"

Creates a new group named "MyGroup" in Azure DevOps using the specified API URI.

.EXAMPLE
New-DevOpsGroup -ApiUri "https://dev.azure.com/myorganization" -GroupName "MyGroup" -ProjectScopeDescriptor "vstfs:///Classification/TeamProject/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

Creates a new group named "MyGroup" in Azure DevOps within the specified project scope.

#>
# Define a function to create a new Azure DevOps Group
Function New-DevOpsGroup
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        # Parameter attribute marks this as a mandatory parameter that the user must supply when calling the function.
        [Parameter(Mandatory = $true)]
        [string]
        $ApiUri, # The URI for the Azure DevOps API.

        # Mandatory parameter for the group name
        [Parameter(Mandatory = $true)]
        [string]
        $GroupName,

        # Optional parameter for the group description with a default value of null
        [Parameter()]
        [String]
        $GroupDescription = $null,

        # Optional parameter for the API version with a default value obtained from the Get-AzDevOpsApiVersion function
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        # Optional parameter for the project scope descriptor
        [Parameter()]
        [String]
        $ProjectScopeDescriptor
    )

    # Hashtable to hold parameters for the API request
    $params = @{
        Uri = '{0}/_apis/graph/groups?api-version={1}' -f $ApiUri, $ApiVersion
        Method = 'Post'
        ContentType = 'application/json'
        Body = @{
            displayName = $GroupName
            description = $GroupDescription
        } | ConvertTo-Json
    }

    # If ProjectScopeDescriptor is provided, modify the URI to include it
    if ($ProjectScopeDescriptor)
    {
        $params.Uri = '{0}/_apis/graph/groups?scopeDescriptor={1}&api-version={2}' -f $ApiUri, $ProjectScopeDescriptor, $ApiVersion
    }

    # Try to invoke the REST method to create the group and return the result
    try
    {
        $group = Invoke-AzDevOpsApiRestMethod @params
        return $group
    }
    # Catch any exceptions and write an error message
    catch
    {
        Write-Error "Failed to create group: $_"
    }
}
