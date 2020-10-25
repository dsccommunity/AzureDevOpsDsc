Function Test-VstsOperation{

    [CmdletBinding()]
    [OutputType([bool])]
    param(
      [Parameter(Mandatory)]
      [Alias('Uri')]
      [string]$VstsServerApiUri,

      [Parameter(Mandatory)]
      [Alias('Pat','PersonalAccessToken')]
      [string]$VstsPat,

      [Parameter(Mandatory)]
      [Alias('OperationId','Id')]
      [string]$VstsOperationId,

      [Parameter(Mandatory,ParameterSetName='IsComplete')]
      [switch]$IsComplete,

      [Parameter(Mandatory,ParameterSetName='IsSuccessful')]
      [switch]$IsSuccessful
    )

    If(!$IsComplete -and !$IsSuccessful){
      throw "The '-IsComplete' switch or the '-IsSuccessful' switch must be used when calling 'Test-VstsOperation'."
      return
    }



    [object[]]$VstsOperation = Get-VstsOperation -VstsServerApiUri $VstsServerApiUri -VstsPat $VstsPat `
                                                 -VstsOperationId $VstsOperationId


    # Note: Operation Statuses listed here:
    #       https://docs.microsoft.com/en-us/rest/api/azure/devops/operations/operations/get?view=azure-devops-rest-6.0#operationstatus
    If($IsSuccessful -and $VstsOperation.status -eq 'succeeded'){
      return $true
    }
    ElseIf($IsComplete -and $VstsOperation.status -in 'succeeded','cancelled','failed'){
      return $true
    }

    # Otherwise, the status is one of 'inProgress', 'notSet' or 'queued'
    return $false


  }