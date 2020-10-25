Function Get-VstsServerApiObject{

    [CmdletBinding()]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$VstsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$VstsPat,

      [Alias('ObjectName')]
      [ValidateSet('Project')]
      [string]$VstsObjectName,

      [Alias('ObjectId')]
      [string]$VstsObjectId
    )

    # Remove any $VstsObjectId if using a wildcard character
    # TODO: Might want to make this more generic (i.e. if !(Test-VstsObjectId $VstsObjectId -IsValid') then set to $null)
    If($VstsObjectId -contains '*'){
      $VstsObjectId = $null
    }

    # TODO: Need something to pluralise and lowercase this object for the URI
    [string]$VstsObjectNamePluralUriString = $VstsObjectName.ToLower() + "s"

    # TODO: Need to get this from input parameter?
    [string]$VstsApiVersionUriParameter = 'api-version=5.1'

    # TODO: Need to generate this from a function
    [string]$VstsServerApiObjectUri = $VstsServerApiUri + "/$VstsObjectNamePluralUriString"
    If(![string]::IsNullOrWhiteSpace($VstsObjectId)){
      $VstsServerApiObjectUri = $VstsServerApiObjectUri + "/$VstsObjectId"
    }
    $VstsServerApiObjectUri = $VstsServerApiObjectUri +  '?' + $VstsApiVersionUriParameter


    [string]$Method = 'Get'
    [hashtable]$VstsServerApiHeader = Get-VstsServerApiHeader -VstsPat $VstsPat

    # TODO: Need to tidy up?
    [object]$VstsServerApiObjects = Invoke-RestMethod -Uri $VstsServerApiObjectUri -Method $Method -Headers $VstsServerApiHeader

    # If not a single, object request, use the object(s) in the 'value' property
    If([string]::IsNullOrWhiteSpace($VstsObjectId)){
      [object[]]$VstsServerApiObjects = $VstsServerApiObjects.value
    }

    return $VstsServerApiObjects
  }
