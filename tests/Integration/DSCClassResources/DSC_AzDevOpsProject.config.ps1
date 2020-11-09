#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

#$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
#if (Test-Path -Path $configFile)
#{
#    <#
#        Allows reading the configuration data from a JSON file,
#        for real testing scenarios outside of the CI.
#    #>
#    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
#}
#else
#{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName                   = 'localhost'

                ApiUri                     = 'InsertApiUriHere'
                Pat                        = 'InsertPatHere'

                #ProjectId                  = 'ac6c91cc-a07f-4b8d-b146-aa6929d2882c'
                ProjectName                = 'TestProjectName'
                ProjectDescription         = 'TestProjectDescription'

                SourceControlType          = 'Git'

                Ensure                     = 'Present'

                #CertificateFile            = $env:DscPublicCertificatePath
            }
        )
    }
#}


<#
    .SYNOPSIS
        Attempts to ensure an Azure DevOps 'Project' (that uses 'Git' for source control) is present.

    .NOTES

#>
Configuration DSC_AzDevOpsProject_EnsureGitProjectPresent_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test_EnsureGitProjectPresent
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = 'TestGitProjectName'
            ProjectDescription  = 'TestGitProjectDescription'

            SourceControlType   = 'Git'

            Ensure              = $Node.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Attempts to ensure an Azure DevOps 'Project' (that uses 'TFVC' for source control) is present.

    .NOTES

#>
Configuration DSC_AzDevOpsProject_EnsureTfvcProjectPresent_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test_EnsureTfvcProjectPresent
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = 'TestTfvcProjectName'
            ProjectDescription  = 'TestTfvcProjectDescription'

            SourceControlType   = 'Tfvc'

            Ensure              = $Node.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Attempts to ensure an Azure DevOps 'Project' is present/added.

    .NOTES

#>
Configuration DSC_AzDevOpsProject_EnsureProjectPresent_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test_EnsureProjectPresent
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = $Node.ProjectName
            ProjectDescription  = $Node.ProjectDescription

            SourceControlType   = $Node.SourceControlType

            Ensure              = $Node.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Attempts to ensure an Azure DevOps 'Project' is present (and remains
        identical to previous state).

    .NOTES

#>
Configuration DSC_AzDevOpsProject_EnsureProjectIdentical_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test_EnsureProjectIdentical
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = $Node.ProjectName
            ProjectDescription  = $Node.ProjectDescription

            SourceControlType   = $Node.SourceControlType

            Ensure              = $Node.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Attempts to ensure an Azure DevOps 'Project' is updated.

    .NOTES

#>
Configuration DSC_AzDevOpsProject_EnsureProjectUpdated_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test_EnsureProjectUpdated
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = $Node.ProjectName
            ProjectDescription  = 'AnAmendedProjectDescription'

            SourceControlType   = $Node.SourceControlType

            Ensure              = $Node.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Attempts to ensure an Azure DevOps 'Project' is updated.

    .NOTES

#>
Configuration DSC_AzDevOpsProject_EnsureProjectRemoved_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test_EnsureProjectRemoved
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = $Node.ProjectName
            #ProjectDescription  = $Node.ProjectDescription

            #SourceControlType   = $Node.SourceControlType

            Ensure              = 'Absent'
        }
    }
}

