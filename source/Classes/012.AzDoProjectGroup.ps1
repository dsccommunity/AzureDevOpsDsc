class AzDoProjectGroup : AzDevOpsDscResourceBase {

    [DscProperty(Key, Mandatory)]
    [System.String]$ProjectName

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$GroupDescription

    [AzDoProjectGroup] Get()
    {
        return [AzDoProjectGroup]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Pat = $this.Pat
            ApiUri = $this.ApiUri
            Ensure = [Ensure]::Absent
        }

        if ($null -ne $CurrentResourceObject)
        {
            if (![System.String]::IsNullOrWhiteSpace($CurrentResourceObject.id))
            {
                $properties.Ensure = [Ensure]::Present
            }
            $properties.ProjectName = $CurrentResourceObject.ProjectName
            $properties.GroupName = $CurrentResourceObject.name
            $properties.GroupDescription = $CurrentResourceObject.description

        }

        return $properties
    }

}
