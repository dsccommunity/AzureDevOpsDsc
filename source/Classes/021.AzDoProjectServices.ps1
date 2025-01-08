<#
.SYNOPSIS
    This class represents an Azure DevOps project and its associated services.

.DESCRIPTION
    The AzDoProjectServices class is a DSC resource that allows you to manage the services associated with an Azure DevOps project. It provides properties to enable or disable various services such as Git repositories, work boards, build pipelines, test plans, and Azure artifacts.

.PARAMETER ProjectName
    The name of the Azure DevOps project.

.PARAMETER GitRepositories
    Specifies whether Git repositories are enabled or disabled for the project. Valid values are 'Enabled' and 'Disabled'. The default value is 'Enabled'.

.PARAMETER WorkBoards
    Specifies whether work boards are enabled or disabled for the project. Valid values are 'Enabled' and 'Disabled'. The default value is 'Enabled'.

.PARAMETER BuildPipelines
    Specifies whether build pipelines are enabled or disabled for the project. Valid values are 'Enabled' and 'Disabled'. The default value is 'Enabled'.

.PARAMETER TestPlans
    Specifies whether test plans are enabled or disabled for the project. Valid values are 'Enabled' and 'Disabled'. The default value is 'Enabled'.

.PARAMETER AzureArtifact
    Specifies whether Azure artifacts are enabled or disabled for the project. Valid values are 'Enabled' and 'Disabled'. The default value is 'Enabled'.

.EXAMPLE
    This example shows how to use the AzDoProjectServices resource to manage the services of an Azure DevOps project.

    Configuration Example {
        Import-DscResource -ModuleName xAzDevOpsDSC

        Node localhost {
            AzDoProjectServices ProjectServices {
                ProjectName     = 'MyProject'
                GitRepositories = 'Enabled'
                WorkBoards      = 'Disabled'
                BuildPipelines  = 'Enabled'
                TestPlans       = 'Disabled'
                AzureArtifact   = 'Enabled'
                Ensure          = 'Present'
            }
        }
    }

.NOTES
    Version: 1.0
    Author: Michael Zanatta
    Required Modules: xAzDevOpsDSC
#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDoProjectServices : AzDevOpsDscResourceBase
{
    [DscProperty(Mandatory, Key)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Repos')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String]$GitRepositories = 'Enabled'

    [DscProperty()]
    [Alias('Board')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String]$WorkBoards = 'Enabled'

    [DscProperty()]
    [Alias('Pipelines')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String]$BuildPipelines = 'Enabled'

    [DscProperty()]
    [Alias('Tests')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String]$TestPlans = 'Enabled'

    [DscProperty()]
    [Alias('Artifacts')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String]$AzureArtifact = 'Enabled'

    AzDoProjectServices()
    {
        $this.Construct()
    }

    [AzDoProjectServices] Get()
    {
        return [AzDoProjectServices]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Ensure = [Ensure]::Absent
        }

        # If the resource object is null, return the properties
        if ($null -eq $CurrentResourceObject)
        {
            return $properties
        }

        $properties.ProjectName         = $CurrentResourceObject.ProjectName
        $properties.GitRepositories     = $CurrentResourceObject.GitRepositories
        $properties.WorkBoards          = $CurrentResourceObject.WorkBoards
        $properties.BuildPipelines      = $CurrentResourceObject.BuildPipelines
        $properties.TestPlans           = $CurrentResourceObject.TestPlans
        $properties.AzureArtifact       = $CurrentResourceObject.AzureArtifact
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult

        Write-Verbose "[AzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
