Function Test-SphVstsEnvironmentCode{

  [CmdletBinding()]
  [OutputType([bool])]
  param(

    [Parameter(Position=0, Mandatory=$true)]
    [Alias('Code','VstsEnvironmentCode')]
    [string]$SphVstsEnvironmentCode
  )

  [string[]]$SphVstsEnvironmentCodes = Get-SphVstsEnvironmentCode

  return $($SphVstsEnvironmentCodes -icontains $SphVstsEnvironmentCode)
}