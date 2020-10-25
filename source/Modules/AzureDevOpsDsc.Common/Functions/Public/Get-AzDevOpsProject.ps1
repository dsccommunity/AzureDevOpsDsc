Function Get-AzDevOpsProject{

    [CmdletBinding()]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$AzDevOpsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$AzDevOpsPat,

      [Alias('ProjectId','Id')]
      [string]$AzDevOpsProjectId = '*',

      [Alias('ProjectName','Name')]
      [string]$AzDevOpsProjectName = '*'
    )

    [string]$AzDevOpsObjectName = 'Project'
    [object[]]$AzDevOpsServerApiObjects = Get-AzDevOpsServerApiObject -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
                                                              -AzDevOpsObjectName $AzDevOpsObjectName `
                                                              -AzDevOpsObjectId $AzDevOpsProjectId

    return $AzDevOpsServerApiObjects |
        Where-Object name -ilike $AzDevOpsProjectName |
        Where-Object id -ilike $AzDevOpsProjectId
  }
