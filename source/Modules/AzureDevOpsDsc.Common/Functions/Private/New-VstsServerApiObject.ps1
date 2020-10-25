Function New-VstsServerApiObject{

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$VstsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$VstsPat,

      [Alias('ObjectName')]
      [ValidateSet('Project')]
      [PsObject]$VstsObjectName,

      [Alias('Object')]
      [PsObject]$VstsObject,

      [switch]$Wait,

      [switch]$Force
    )

    [string]$VstsObjectId = $VstsObject.id

    # TODO: Need something to pluralise and lowercase this object for the URI
    [string]$VstsObjectNamePluralUriString = $VstsObjectName.ToLower() + "s"

    # TODO: Need something to convert to JSON
    [string]$VstsObjectJson = $VstsObject | ConvertTo-Json -Depth 10 -Compress

    # TODO: Need to get this from input parameter?
    [string]$VstsApiVersionUriParameter = 'api-version=5.1'

    # TODO: Need to generate this from a function
    [string]$VstsServerApiObjectUri = $VstsServerApiUri + "/$VstsObjectNamePluralUriString" +  '?' + $VstsApiVersionUriParameter


    [string]$Method = 'Post'
    [string]$ContentType = 'application/json'
    [hashtable]$VstsServerApiHeader = Get-VstsServerApiHeader -VstsPat $VstsPat

    # TODO: Need to tidy up?

    [object]$VstsServerApiOperation = $null

    if ($Force -or $PSCmdlet.ShouldProcess($VstsServerApiObjectUri,$VstsObjectName)) {

      [object]$VstsServerApiOperation = Invoke-RestMethod -Uri $VstsServerApiObjectUri -Method $Method -Headers $VstsServerApiHeader -Body $VstsObjectJson -ContentType $ContentType

      If($Wait){

        Wait-VstsOperation -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
                           -VstsOperationId $VstsOperationId `
                           -IsSuccessful

        Get-VstsServerApiObject -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
                                -VstsObjectName $VstsObjectName `
                                -VstsObjectId $VstsObjectId
      }

    }


  }
