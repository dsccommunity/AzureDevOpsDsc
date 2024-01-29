
<#
    .DESCRIPTION
        This example shows how to ensure that the Azure DevOps project
        called 'Test Project' exists (or is added if it does not exist).
        This example uses Invoke-DSCResource to authenticate to Azure DevOps using a Managed Identity.
#>

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ApiUri
    )

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        AzDevOpsProject 'AddProject'
        {
            Ensure               = 'Present'

            ApiUri               = $ApiUri
            Pat                  = $Pat

            ProjectName          = 'Test Project'
            ProjectDescription   = 'A Test Project'

            SourceControlType    = 'Git'
        }

    }
}

# Create a new Azure Managed Identity and store the token in a global variable
New-AzManagedIdentity -OrganizationName "Contoso"

# Using Invoke-DSCResource, invoke the 'Test' method of the 'AzDevOpsProject' resource.
# The global variable will be used to authenticate to Azure DevOps.
Invoke-DscResource -Name Example -Method Test -Verbose
