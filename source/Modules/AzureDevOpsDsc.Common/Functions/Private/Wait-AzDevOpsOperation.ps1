function Wait-AzDevOpsOperation {

  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [Alias('Uri')]
    [string]$AzDevOpsServerApiUri,

    [Parameter(Mandatory)]
    [Alias('Pat', 'PersonalAccessToken')]
    [string]$AzDevOpsPat,

    [Parameter(Mandatory)]
    [Alias('OperationId', 'Id')]
    [string]$AzDevOpsOperationId,

    [Alias('IntervalMilliseconds')]
    [int]$WaitIntervalMilliseconds = 500,

    [Alias('TimeoutMilliseconds')]
    [int]$WaitTimeoutMilliseconds = 30000, # 30 seconds

    [Parameter(Mandatory, ParameterSetName = 'IsComplete')]
    [switch]$IsComplete,

    [Parameter(Mandatory, ParameterSetName = 'IsSuccessful')]
    [switch]$IsSuccessful
  )

  If (!$IsComplete -and !$IsSuccessful) {
    throw "The '-IsComplete' switch or the '-IsSuccessful' switch must be used when calling 'Test-AzDevOpsOperation'."
    return
  }
  ElseIf (!$IsComplete -and !$IsSuccessful) {
    throw "Only the '-IsComplete' switch or the alternative '-IsSuccessful' switch must be used when calling 'Test-AzDevOpsOperation'."
    return
  }

  [DateTime]$WaitStartDateTime = [DateTime]::UtcNow

  while (!(Test-AzDevOpsOperation -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
        -AzDevOpsOperationId $AzDevOpsOperationId `
        -IsComplete:$IsComplete -IsSuccessful:$IsSuccessful)) {

    Start-Sleep -Milliseconds $WaitIntervalMilliseconds

    if ($(New-TimeSpan -Start $WaitStartDateTime -End $([DateTime]::UtcNow)).Milliseconds -gt $WaitTimeoutMilliseconds) {
      throw "The 'Wait-AzDevOpsOperation' operation for AzDevOpsOperationId of '$AzDevOpsOperationId' exceeded specified, maximum timeout ($WaitTimeoutMilliseconds milliseconds)"
      return
    }

  }

}
