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

                #CertificateFile            = $env:DscPublicCertificatePath
            }
        )
    }
#}


<#
    .SYNOPSIS
        Reverts the SQL Server Agent service account of the default instance to
        the original account that was initially used during installation.

    .NOTES
        This test is intentionally meant to run using the credentials in
        $SqlInstallCredential.
#>
Configuration DSC_AzDevOpsProject_EnsureProjectPresent_Config
{
    Import-DscResource -ModuleName 'AzureDevOpsDsc' -Name 'DSC_AzDevOpsProject'

    node $AllNodes.NodeName
    {
        DSC_AzDevOpsProject Integration_Test
        {
            ApiUri              = $Node.ApiUri
            Pat                 = $Node.Pat

            #ProjectId           = $Node.ProjectId
            ProjectName         = $Node.ProjectName
            ProjectDescription  = $Node.ProjectDescription

            Ensure              = $Node.Ensure
        }
    }
}
