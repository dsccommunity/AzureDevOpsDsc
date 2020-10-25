Function New-AzDevOpsProject{

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$AzDevOpsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$AzDevOpsPat,

      [Parameter(Mandatory)]
      [Alias('ProjectId','Id')]
      [string]$AzDevOpsProjectId,

      [Parameter(Mandatory)]
      [Alias('ProjectName','Name')]
      [string]$AzDevOpsProjectName,

      [Parameter(Mandatory)]
      [Alias('ProjectDescription','Description')]
      [string]$AzDevOpsProjectDescription,

      [Parameter(Mandatory)]
      [Alias('SourceControlType')]
      [ValidateSet('Git')]
      [string]$AzDevOpsSourceControlType,

      [switch]$Force
    )

    [string]$AzDevOpsObjectName = 'Project'

    [string]$AzDevOpsObjectJson = '
    {
      "id": "'+ $AzDevOpsProjectId +'",
      "name": "'+ $AzDevOpsProjectName +'",
      "description": "'+ $AzDevOpsProjectDescription +'",
      "capabilities": {
        "versioncontrol": {
          "sourceControlType": "'+ $AzDevOpsSourceControlType +'"
        },
        "processTemplate": {
          "templateTypeId": "6b724908-ef14-45cf-84f8-768b5384da45"
        }
      }
    }
'

    [object]$AzDevOpsObject = $null

    if ($Force -or $PSCmdlet.ShouldProcess($AzDevOpsServerApiUri,$AzDevOpsObjectName)) {

      [object]$AzDevOpsObject = New-AzDevOpsServerApiObject -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
                                                    -AzDevOpsObjectName $AzDevOpsObjectName `
                                                    -AzDevOpsObject $($AzDevOpsObjectJson | ConvertFrom-Json) `
                                                    -Force:$Force
    }

    return $AzDevOpsObject
  }
