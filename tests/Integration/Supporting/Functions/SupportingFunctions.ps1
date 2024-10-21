

Function New-Project {
    param(
        [string]$ProjectName
    )

    #
    # Create a new project

    $projectParams = @{
        Name = 'AzDoProject'
        ModuleName = 'AzureDevOpsDsc'
        Method = 'Set'
        property = @{
            ProjectName = $PROJECTNAME
        }
    }

    # Invoke the DSC resource to create a new project.
    $null = Invoke-DscResource @projectParams

}

Function New-Repository {
    param(
        [string]$ProjectName,
        [string]$RepositoryName
    )

    #
    # Create a new repository

    $parameters = @{
        Name = 'AzDoGitRepository'
        ModuleName = 'AzureDevOpsDsc'
        Method = 'Set'
        property = @{
            ProjectName = $PROJECTNAME
            RepositoryName = $RepositoryName
        }
    }

    # Invoke the DSC resource to create a new project.
    $null = Invoke-DscResource @parameters

}



Function New-Group {
    param(
        [string]$ProjectName,
        [string]$GroupName
    )

    #
    # Create a new group

    $groupParams = @{
        Name = 'AzDoProjectGroup'
        ModuleName = 'AzureDevOpsDsc'
        Method = 'Set'
        property = @{
            ProjectName = $PROJECTNAME
            GroupName = $GroupName
        }
    }

    # Create that group
    $null = Invoke-DscResource @groupParams

}
