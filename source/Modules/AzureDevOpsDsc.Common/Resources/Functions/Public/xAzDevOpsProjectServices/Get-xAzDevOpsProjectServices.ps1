Function Get-xAzDevOpsProjectServices {

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

    #
    # Construct a hashtable detailing the group

    $Result = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        status = [DSCGetSummaryState]::Unchanged
    }

    #
    # Attempt to retrive the Project from the Live Cache.
    Write-Verbose "[Get-xAzDevOpsProjectServices] Retriving the Project from the Live Cache."

    # Retrive the Repositories from the Live Cache.
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # If the Project does not exist in the Live Cache, return the Project object.
    if ($null -eq $Project) {
        Write-Verbose "[Get-xAzDevOpsProjectServices] The Project '$ProjectName' was not found in the Live Cache."
        Throw "[Get-xAzDevOpsProjectServices] The Project '$ProjectName' was not found in the Live Cache."
    }

    $params = @{
        Organization = $Global:DSCAZDO_OrganizationName
        ProjectId    = $Project.ProjectId
    }

    # Enumerate the Project Services.
    $Result.LiveServices = @{
        Repos       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Repos
        Boards      = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Boards
        Pipelines   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Pipelines
        Tests       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_TestPlans
        Artifacts   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Artifacts
    }

    # Compare the Project Services with the desired state.
    if ($GitRepositories -ne $ProjectServices.Repos) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += 'Repos'
    }
    if ($WorkBoards -ne $ProjectServices.Boards) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += 'Boards'
    }
    if ($BuildPipelines -ne $ProjectServices.Pipelines) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += 'Pipelines'
    }
    if ($TestPlans -ne $ProjectServices.Tests) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += 'Tests'
    }
    if ($AzureArtifact -ne $ProjectServices.Artifacts) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += 'Artifacts'
    }

}
