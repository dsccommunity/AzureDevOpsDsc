using namespace AzureDevOpsDsc.Common

class AzDoOrganizationGroupPermission : AzDevOpsDscResourceBase {

    [DscProperty(Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty(Mandatory)]
    [Alias('Permission')]
    [AzDoOrganizationGroupPermission[]]$GroupPermission

    [AzDoOrganizationGroupPermission] Get()
    {
        return [AzDoProjectGroupPermission]$($this.GetDscCurrentStateProperties())
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
            $properties.GroupPermission = $CurrentResourceObject.permission
        }

        return $properties
    }

}

