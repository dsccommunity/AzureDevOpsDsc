using module AzureDevOpsDsc.Common

class xAzDoProjectGroupPermission : AzDevOpsDscResourceBase
{
    [DscProperty()]
    [Alias('Id')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty()]
    [Alias('Permission')]
    [xAzDoProjectGroupPermission[]]$GroupPermission

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
            $properties.ProjectName = $CurrentResourceObject.name
            $properties.GroupName = $CurrentResourceObject.name
            $properties.GroupPermission = $CurrentResourceObject.permission

        }
        return $properties

    }

}

