Function Get-SphVstsServerUri{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ValidateScript({Test-SphVstsEnvironmentCode -VstsEnvironmentCode $_})]
    [Alias('EnvironmentCode','VstsEnvironmentCode','SphEnvironmentCode')]
    [String]$SphVstsEnvironmentCode

  )

  [string]$SphVstsOrganizationName = Get-SphVstsOrganizationName -SphVstsEnvironmentCode $SphVstsEnvironmentCode
  [string]$SphVstsServerUri = Get-VstsServerUri -VstsOrganizationName $SphVstsOrganizationName

  return $SphVstsServerUri
}