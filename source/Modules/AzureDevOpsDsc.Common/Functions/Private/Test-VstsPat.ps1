Function Test-VstsPat{

  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Alias('Pat')]
    [string]$VstsPat,

    [switch]$IsValid
  )

  If(!$IsValid){
    throw "The '-IsValid' switch must be used when calling 'Test-VstsPat'."
    return
  }

  If([string]::IsNullOrWhiteSpace($VstsPat)){
    return $false
  }
  ElseIf($VstsPat.Length -ne 52){
    return $false
  }

  return $true
}
