using module AzureDevOpsDsc.Common

class AzDoGitPermission : AzDevOpsDscResourceBase {

    [DscProperty(Mandatory)]
    [Alias('ProjectName')]
    [System.String]$ProjectName

    [DscProperty(Mandatory)]
    [Alias('Name')]
    [System.String]$GitRepositoryName

    [DscProperty(Mandatory)]
    [AzDoGitRepositoryPermission[]]$Permission

    [AzDoGitPermission] Get()
    {
        return [AzDoGitPermission]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @('SourceControlType')
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
            $properties.ProjectId = $CurrentResourceObject.id
            $properties.ProjectName = $CurrentResourceObject.name
            $properties.ProjectDescription = $CurrentResourceObject.description
            $properties.SourceControlType = $CurrentResourceObject.capabilities.versioncontrol.sourceControlType
        }

        return $properties
    }

}

