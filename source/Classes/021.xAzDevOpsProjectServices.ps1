
[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDevOpsProjectServices : AzDevOpsDscResourceBase
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

    xAzDevOpsProjectServices()
    {
        $this.Construct()
    }

    [xAzDevOpsProjectServices] Get()
    {
        return [xAzDevOpsProjectServices]$($this.GetDscCurrentStateProperties())
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
        if ($null -eq $CurrentResourceObject) { return $properties }

        $properties.ProjectName         = $CurrentResourceObject.ProjectName
        $properties.GitRepositories     = $CurrentResourceObject.GitRepositories
        $properties.WorkBoards          = $CurrentResourceObject.WorkBoards
        $properties.BuildPipelines      = $CurrentResourceObject.BuildPipelines
        $properties.TestPlans           = $CurrentResourceObject.TestPlans
        $properties.AzureArtifact       = $CurrentResourceObject.AzureArtifact
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult

        Write-Verbose "[xAzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
