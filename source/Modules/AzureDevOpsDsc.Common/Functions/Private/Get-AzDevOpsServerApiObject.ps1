function Get-AzDevOpsServerApiObject{

    [CmdletBinding()]
    [OutputType([object[]])]
    param(
      [Alias('Uri')]
      [string]$AzDevOpsServerApiUri,

      [Alias('Pat','PersonalAccessToken')]
      [string]$AzDevOpsPat,

      [Alias('ObjectName')]
      [ValidateSet('Project')]
      [string]$AzDevOpsObjectName,

      [Alias('ObjectId')]
      [string]$AzDevOpsObjectId
    )

    # Remove any $AzDevOpsObjectId if using a wildcard character
    # TODO: Might want to make this more generic (i.e. if !(Test-AzDevOpsObjectId $AzDevOpsObjectId -IsValid') then set to $null)
    If($AzDevOpsObjectId -contains '*'){
      $AzDevOpsObjectId = $null
    }

    # TODO: Need something to pluralise and lowercase this object for the URI
    [string]$AzDevOpsObjectNamePluralUriString = $AzDevOpsObjectName.ToLower() + "s"

    # TODO: Need to get this from input parameter?
    [string]$AzDevOpsApiVersionUriParameter = 'api-version=5.1'

    # TODO: Need to generate this from a function
    [string]$AzDevOpsServerApiObjectUri = $AzDevOpsServerApiUri + "/$AzDevOpsObjectNamePluralUriString"
    If(![string]::IsNullOrWhiteSpace($AzDevOpsObjectId)){
      $AzDevOpsServerApiObjectUri = $AzDevOpsServerApiObjectUri + "/$AzDevOpsObjectId"
    }
    $AzDevOpsServerApiObjectUri = $AzDevOpsServerApiObjectUri +  '?' + $AzDevOpsApiVersionUriParameter


    [string]$Method = 'Get'
    [hashtable]$AzDevOpsServerApiHeader = Get-AzDevOpsApiHttpRequestHeader -AzDevOpsPat $AzDevOpsPat

    # TODO: Need to tidy up?
    [object]$AzDevOpsServerApiObjects = Invoke-RestMethod -Uri $AzDevOpsServerApiObjectUri -Method $Method -Headers $AzDevOpsServerApiHeader

    # If not a single, object request, use the object(s) in the 'value' property
    If([string]::IsNullOrWhiteSpace($AzDevOpsObjectId)){
      [object[]]$AzDevOpsServerApiObjects = $AzDevOpsServerApiObjects.value
    }

    return $AzDevOpsServerApiObjects
  }
