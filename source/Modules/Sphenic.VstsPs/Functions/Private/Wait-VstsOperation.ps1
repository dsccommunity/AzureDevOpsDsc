Function Wait-VstsOperation {

  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [Alias('Uri')]
    [string]$VstsServerApiUri,

    [Parameter(Mandatory)]
    [Alias('Pat', 'PersonalAccessToken')]
    [string]$VstsPat,

    [Parameter(Mandatory)]
    [Alias('OperationId', 'Id')]
    [string]$VstsOperationId,

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
    throw "The '-IsComplete' switch or the '-IsSuccessful' switch must be used when calling 'Test-VstsOperation'."
    return
  }
  ElseIf (!$IsComplete -and !$IsSuccessful) {
    throw "Only the '-IsComplete' switch or the alternative '-IsSuccessful' switch must be used when calling 'Test-VstsOperation'."
    return
  }

  [DateTime]$WaitStartDateTime = [DateTime]::UtcNow

  while (!(Test-VstsOperation -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
        -VstsOperationId $VstsOperationId `
        -IsComplete:$IsComplete -IsSuccessful:$IsSuccessful)) {

    Start-Sleep -Milliseconds $WaitIntervalMilliseconds

    if ($(New-TimeSpan -Start $WaitStartDateTime -End $([DateTime]::UtcNow)).Milliseconds -gt $WaitTimeoutMilliseconds) {
      throw "The 'Wait-VstsOperation' operation for VstsOperationId of '$VstsOperationId' exceeded specified, maximum timeout ($WaitTimeoutMilliseconds milliseconds)"
      return
    }

  }

}
