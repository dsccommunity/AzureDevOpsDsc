
<#
    .DESCRIPTION
        This example shows how to ensure that the Azure DevOps project
        called 'Test Project' exists (or is added if it does not exist).
#>

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $true)]
        [string]
        $Pat
    )

    Import-DscResource -ModuleName 'AzureDevOpsDsc'

    node localhost
    {
        DSC_AzDevOpsProject 'AddProject'
        {
            Ensure               = 'Present'

            ApiUri               = $ApiUri
            Pat                  = $Pat

            ProjectName          = 'Test Project'
            ProjectDescription   = 'A Test Project'

            #ProjectId            = 'TestProject'
        }

    }
}
