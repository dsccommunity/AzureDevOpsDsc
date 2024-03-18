class xAzDoOrganizationGroup : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty(Key, Mandatory)]
    [Alias('DisplayName')]
    [System.String]$GroupDisplayName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$GroupDescription

    [xAzDoOrganizationGroup] Get()
    {
        return [xAzDoOrganizationGroup]$($this.GetDscCurrentStateProperties())
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
            $properties.GroupName = $CurrentResourceObject.name
            $properties.GroupDescription = $CurrentResourceObject.description
            $properties.GroupDisplayName = $CurrentResourceObject.displayName
        }

        return $properties
    }

}
