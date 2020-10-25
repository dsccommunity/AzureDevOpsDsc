Function New-VstsProject{

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$VstsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$VstsPat,

      [Parameter(Mandatory)]
      [Alias('ProjectId','Id')]
      [string]$VstsProjectId,

      [Parameter(Mandatory)]
      [Alias('ProjectName','Name')]
      [string]$VstsProjectName,

      [Parameter(Mandatory)]
      [Alias('ProjectDescription','Description')]
      [string]$VstsProjectDescription,

      [Parameter(Mandatory)]
      [Alias('SourceControlType')]
      [ValidateSet('Git')]
      [string]$VstsSourceControlType,

      [switch]$Force
    )

    [string]$VstsObjectName = 'Project'

    [string]$VstsObjectJson = '
    {
      "id": "'+ $VstsProjectId +'",
      "name": "'+ $VstsProjectName +'",
      "description": "'+ $VstsProjectDescription +'",
      "capabilities": {
        "versioncontrol": {
          "sourceControlType": "'+ $VstsSourceControlType +'"
        },
        "processTemplate": {
          "templateTypeId": "6b724908-ef14-45cf-84f8-768b5384da45"
        }
      }
    }
'

    [object]$VstsObject = $null

    if ($Force -or $PSCmdlet.ShouldProcess($VstsServerApiUri,$VstsObjectName)) {

      [object]$VstsObject = New-VstsServerApiObject -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
                                                    -VstsObjectName $VstsObjectName `
                                                    -VstsObject $($VstsObjectJson | ConvertFrom-Json) `
                                                    -Force:$Force
    }

    return $VstsObject
  }