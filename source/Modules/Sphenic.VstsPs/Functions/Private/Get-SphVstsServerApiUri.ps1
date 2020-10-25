Function Get-SphVstsServerApiUri{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ArgumentCompleter({Get-SphVstsEnvironmentCode})]
    [ValidateScript({Test-SphVstsEnvironmentCode -VstsEnvironmentCode $_})]
    [Alias('EnvironmentCode','VstsEnvironmentCode','SphEnvironmentCode')]
    [String]$SphVstsEnvironmentCode

  )

  [string]$SphVstsServerUri = Get-SphVstsServerUri -SphVstsEnvironmentCode $SphVstsEnvironmentCode

  return $SphVstsServerUri + "_apis"
}