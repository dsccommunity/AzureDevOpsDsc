function New-AzDevOpsServerApiObject{

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$AzDevOpsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$AzDevOpsPat,

      [Alias('ObjectName')]
      [ValidateSet('Project')]
      [PsObject]$AzDevOpsObjectName,

      [Alias('Object')]
      [PsObject]$AzDevOpsObject,

      [switch]$Wait,

      [switch]$Force
    )

    [string]$AzDevOpsObjectId = $AzDevOpsObject.id

    # TODO: Need something to pluralise and lowercase this object for the URI
    [string]$AzDevOpsObjectNamePluralUriString = $AzDevOpsObjectName.ToLower() + "s"

    # TODO: Need something to convert to JSON
    [string]$AzDevOpsObjectJson = $AzDevOpsObject | ConvertTo-Json -Depth 10 -Compress

    # TODO: Need to get this from input parameter?
    [string]$AzDevOpsApiVersionUriParameter = 'api-version=5.1'

    # TODO: Need to generate this from a function
    [string]$AzDevOpsServerApiObjectUri = $AzDevOpsServerApiUri + "/$AzDevOpsObjectNamePluralUriString" +  '?' + $AzDevOpsApiVersionUriParameter


    [string]$Method = 'Post'
    [string]$ContentType = 'application/json'
    [hashtable]$AzDevOpsServerApiHeader = Get-AzDevOpsServerApiHeader -AzDevOpsPat $AzDevOpsPat

    # TODO: Need to tidy up?

    [object]$AzDevOpsServerApiOperation = $null

    if ($Force -or $PSCmdlet.ShouldProcess($AzDevOpsServerApiObjectUri,$AzDevOpsObjectName)) {

      [object]$AzDevOpsServerApiOperation = Invoke-RestMethod -Uri $AzDevOpsServerApiObjectUri -Method $Method -Headers $AzDevOpsServerApiHeader -Body $AzDevOpsObjectJson -ContentType $ContentType

      If($Wait){

        Wait-AzDevOpsOperation -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
                           -AzDevOpsOperationId $AzDevOpsOperationId `
                           -IsSuccessful

        Get-AzDevOpsServerApiObject -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
                                -AzDevOpsObjectName $AzDevOpsObjectName `
                                -AzDevOpsObjectId $AzDevOpsObjectId
      }

    }


  }
