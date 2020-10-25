function Get-AzDevOpsOperation{

    [CmdletBinding()]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$AzDevOpsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$AzDevOpsPat,

      [Alias('OperationId','Id')]
      [string]$AzDevOpsOperationId = '*'
    )

    [string]$AzDevOpsObjectName = 'Operation'
    [object[]]$AzDevOpsServerApiObjects = Get-AzDevOpsServerApiObject -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
                                                              -AzDevOpsObjectName $AzDevOpsObjectName -AzDevOpsObjectId $AzDevOpsOperationId

    return $AzDevOpsServerApiObjects |
        Where-Object id -ilike $AzDevOpsOperationId
  }
