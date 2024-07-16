
#[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoProjectGroupPermission : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty(Mandatory)]
    [Alias('Project')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Inherited')]
    [System.Boolean]$isInherited=$true

    [DscProperty(Mandatory)]
    [HashTable]$Permission

    xAzDoProjectGroupPermission()
    {
        $this.Construct()
    }

    [xAzDoProjectGroupPermission] Get()
    {
        return [xAzDoProjectGroupPermission]$($this.GetDscCurrentStateProperties())
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

        $properties.ProjectName           = $CurrentResourceObject.ProjectName
        $properties.GroupName             = $CurrentResourceObject.GroupName
        $properties.isInherited           = $CurrentResourceObject.isInherited
        $properties.Permission            = $CurrentResourceObject.Permission
        $properties.lookupResult          = $CurrentResourceObject.lookupResult
        $properties.Ensure                = $CurrentResourceObject.Ensure

        Write-Verbose "[xAzDoProjectGroupPermission] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
