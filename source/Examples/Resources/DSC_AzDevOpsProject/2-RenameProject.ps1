
<#
    .DESCRIPTION
        This example shows how to ensure that an Azure DevOps project
        with a ProjectId of '1aeda1ef-a16d-4118-8817-d2f85d4f05d1' can be
        renamed to 'A New Test Project Name'.
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
        DSC_AzDevOpsProject 'RenameProject'
        {
            Ensure               = 'Present'

            ApiUri               = $ApiUri
            Pat                  = $Pat

            ProjectId            = '1aeda1ef-a16d-4118-8817-d2f85d4f05d1'  # Example ProjectId (NOTE: This is mandatory for renaming a project)
            ProjectName          = 'A New Test Project Name'
            ProjectDescription   = 'A test project'

        }

    }
}
