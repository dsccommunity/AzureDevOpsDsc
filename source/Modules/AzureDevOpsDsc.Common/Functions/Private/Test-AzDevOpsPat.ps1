function Test-AzDevOpsPat{

  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Alias('Pat')]
    [string]$AzDevOpsPat,

    [switch]$IsValid
  )

  If(!$IsValid){
    throw "The '-IsValid' switch must be used when calling 'Test-AzDevOpsPat'."
    return
  }

  If([string]::IsNullOrWhiteSpace($AzDevOpsPat)){
    return $false
  }
  ElseIf($AzDevOpsPat.Length -ne 52){
    return $false
  }

  return $true
}
