Function Get-AzDevOpsServerApiHeader{

  [CmdletBinding()]
  [OutputType([hashtable])]
  param(

    [ValidateScript({Test-AzDevOpsPat -AzDevOpsPat $_ -IsValid})]
    [Alias('Pat', 'PersonalAccessToken')]
    [string]$AzDevOpsPat

  )

  [hashtable]$AzDevOpsServerApiHeader = @{
    Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzDevOpsPat)"))
  }

  return $AzDevOpsServerApiHeader
}
