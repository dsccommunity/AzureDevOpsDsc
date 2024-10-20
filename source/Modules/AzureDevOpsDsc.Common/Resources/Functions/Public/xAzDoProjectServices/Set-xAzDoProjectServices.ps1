Function Set-xAzDoProjectServices {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$ProjectName,

        [Parameter()]
        [Alias('Repos')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$GitRepositories = 'Enabled',

        [Parameter()]
        [Alias('Board')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$WorkBoards = 'Enabled',

        [Parameter()]
        [Alias('Pipelines')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$BuildPipelines = 'Enabled',

        [Parameter()]
        [Alias('Tests')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$TestPlans = 'Enabled',

        [Parameter()]
        [Alias('Artifacts')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$AzureArtifact = 'Enabled',

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    # Retrive the Repositories from the Live Cache.
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # Construct a hashtable detailing the group
    ForEach ($PropertyChanged in $LookupResult.propertiesChanged) {

        $params = @{
            Organization = $Global:DSCAZDO_OrganizationName
            ProjectId    = $Project.id
            ServiceName  = $PropertyChanged.FeatureId
            Body         = $LookupResult.LiveServices.Keys | Where-Object { $LookupResult.LiveServices[$_].featureId -eq $PropertyChanged.FeatureId } | ForEach-Object { $LookupResult.LiveServices[$_] }
        }

        # Set the Project Service Status
        $params.Body.state = ($PropertyChanged.Expected -eq 'Enabled') ? 1 : 0

        Set-ProjectServiceStatus @params

    }

}
