
#[DscResource()]
#[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoGitPermission : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty(Mandatory)]
    [Alias('Repository')]
    [System.String]$RepositoryName

    [DscProperty()]
    [Alias('Inherited')]
    [System.Boolean]$isInherited=$true

    [DscProperty(Mandatory)]
    [Alias('Members')]
    [HashTable[]]$Permissions

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

        $properties.GroupName           = $CurrentResourceObject.GroupName
        $properties.GroupMembers        = $CurrentResourceObject.GroupMembers
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult

        Write-Verbose "[xAzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
