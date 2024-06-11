[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoGitRepository : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty(Key, Mandatory)]
    [Alias('Repository')]
    [System.String]$GitRepositoryName

    [DscProperty()]
    [Alias('Source')]
    [System.String]$SourceRepository

    xAzDoGroupMember()
    {
        $this.Construct()
    }

    [xAzDoGroupMember] Get()
    {
        return [xAzDoGroupMember]$($this.GetDscCurrentStateProperties())
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

        $properties.ProjectName         = $CurrentResourceObject.Name
        $properties.GitRepositoryName   = $CurrentResourceObject.Repository
        $properties.SourceRepository    = $CurrentResourceObject.Source
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult

        Write-Verbose "[xAzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
