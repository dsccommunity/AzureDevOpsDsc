Function Get-VstsOperation{

    [CmdletBinding()]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$VstsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$VstsPat,

      [Alias('OperationId','Id')]
      [string]$VstsOperationId = '*'
    )

    [string]$VstsObjectName = 'Operation'
    [object[]]$VstsServerApiObjects = Get-VstsServerApiObject -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
                                                              -VstsObjectName $VstsObjectName -VstsObjectId $VstsOperationId

    return $VstsServerApiObjects |
        Where-Object id -ilike $VstsOperationId
  }