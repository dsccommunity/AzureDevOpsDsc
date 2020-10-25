Function Get-SphVstsOrganizationName{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ValidateScript({Test-SphVstsEnvironmentCode -VstsEnvironmentCode $_})]
    [Alias('EnvironmentCode','VstsEnvironmentCode','SphEnvironmentCode')]
    [String]$SphVstsEnvironmentCode

  )

  [hashtable]$SphVstsEnvironmentCodeOrganisationNames = @{
    'LV' = 'Sphenic'
    'LS' = 'Sphenic-LS'
    'TS' = 'Sphenic-TS'
    'TI' = 'Sphenic-TI'
  }

  [string]$SphVstsOrganizationName = $SphVstsEnvironmentCodeOrganisationNames[$SphVstsEnvironmentCode]

  If([string]::IsNullOrWhiteSpace($SphVstsOrganizationName)){
    throw "Cannot obtain 'SphVstsOrganizationName' value for SphVstsEnvironmentCode of '$SphVstsEnvironmentCode'. Corresponding value does not exist."
  }

  return $SphVstsEnvironments[$SphVstsEnvironmentCode]
}
