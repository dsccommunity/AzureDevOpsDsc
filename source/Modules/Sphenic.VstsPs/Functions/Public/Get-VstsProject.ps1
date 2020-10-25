Function Get-VstsProject{

    [CmdletBinding()]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$VstsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$VstsPat,

      [Alias('ProjectId','Id')]
      [string]$VstsProjectId = '*',

      [Alias('ProjectName','Name')]
      [string]$VstsProjectName = '*'
    )

    [string]$VstsObjectName = 'Project'
    [object[]]$VstsServerApiObjects = Get-VstsServerApiObject -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
                                                              -VstsObjectName $VstsObjectName `
                                                              -VstsObjectId $VstsProjectId

    return $VstsServerApiObjects |
        Where-Object name -ilike $VstsProjectName |
        Where-Object id -ilike $VstsProjectId
  }