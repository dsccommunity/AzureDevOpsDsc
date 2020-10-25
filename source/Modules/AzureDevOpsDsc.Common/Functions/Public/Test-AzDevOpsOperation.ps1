function Test-AzDevOpsOperation{

    [CmdletBinding()]
    [OutputType([bool])]
    param(
      [Parameter(Mandatory)]
      [Alias('Uri')]
      [string]$AzDevOpsServerApiUri,

      [Parameter(Mandatory)]
      [Alias('Pat','PersonalAccessToken')]
      [string]$AzDevOpsPat,

      [Parameter(Mandatory)]
      [Alias('OperationId','Id')]
      [string]$AzDevOpsOperationId,

      [Parameter(Mandatory,ParameterSetName='IsComplete')]
      [switch]$IsComplete,

      [Parameter(Mandatory,ParameterSetName='IsSuccessful')]
      [switch]$IsSuccessful
    )

    if(!$IsComplete -and !$IsSuccessful){
      throw "The '-IsComplete' switch or the '-IsSuccessful' switch must be used when calling 'Test-AzDevOpsOperation'."
      return
    }



    [object[]]$AzDevOpsOperation = Get-AzDevOpsOperation -AzDevOpsServerApiUri $AzDevOpsServerApiUri -AzDevOpsPat $AzDevOpsPat `
                                                 -AzDevOpsOperationId $AzDevOpsOperationId


    # Note: Operation Statuses listed here:
    #       https://docs.microsoft.com/en-us/rest/api/azure/devops/operations/operations/get?view=azure-devops-rest-6.0#operationstatus
    if($IsSuccessful -and $AzDevOpsOperation.status -eq 'succeeded'){
      return $true
    }
    elseIf($IsComplete -and $AzDevOpsOperation.status -in 'succeeded','cancelled','failed'){
      return $true
    }

    # Otherwise, the status is one of 'inProgress', 'notSet' or 'queued'
    return $false


  }
