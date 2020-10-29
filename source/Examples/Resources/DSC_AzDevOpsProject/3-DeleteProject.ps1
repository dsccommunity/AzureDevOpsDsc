
<#
    .DESCRIPTION
        This example shows both how to ensure that an Azure DevOps project
        can be logically deleted or be unequivocally/hard deleted.
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

        # Example: A logical delete (rename) of a project
        DSC_AzDevOpsProject 'DeleteProject_Logical'
        {
            Ensure               = 'Absent'

            ApiUri               = $ApiUri
            Pat                  = $Pat

            ProjectName          = 'Test Logical Delete Project'
            ProjectDescription   = 'A test project to be logically deleted'

            # An optional, prefix for logically deleted Projects (default is 'zzDel_')
            DeletedPrefix         = 'zzDel_'

        }


        # Example: An unequivocal delete of a project (i.e. a strong/pure/absolute delete)
        DSC_AzDevOpsProject 'DeleteProject_Unequivocal'
        {
            Ensure               = 'Absent'

            ApiUri               = $ApiUri
            Pat                  = $Pat

            ProjectName          = 'Test Unequivocal Delete Project'
            ProjectDescription   = 'A test project to be unequivocally deleted'

            # NOTE: By specifying the Force parameter, this will perform an actual delete of the project (as opposed to a logical delete)
            Force                = $true

        }

    }
}
