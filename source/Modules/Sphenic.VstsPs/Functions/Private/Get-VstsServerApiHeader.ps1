Function Get-VstsServerApiHeader{

  [CmdletBinding()]
  [OutputType([hashtable])]
  param(

    [ValidateScript({Test-VstsPat -VstsPat $_ -IsValid})]
    [Alias('Pat', 'PersonalAccessToken')]
    [string]$VstsPat

  )

  [hashtable]$VstsServerApiHeader = @{
    Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($VstsPat)"))
  }

  return $VstsServerApiHeader
}
