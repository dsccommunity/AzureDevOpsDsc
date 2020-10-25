Function Get-SphVstsEnvironmentCode{

  [CmdletBinding()]
  [OutputType([string[]])]
  param(

    [Alias('Code','EnvironmentCode','VstsEnvironmentCode','SphEnvironmentCode')]
    [string]$SphVstsEnvironmentCode = '*'
  )

  [string[]]$SphVstsEnvironmentCodes = @(
    'TI', 'TS', 'LS', 'LV'
  )

  return $SphVstsEnvironmentCodes |
    Where-Object -ilike $SphVstsEnvironmentCode

}