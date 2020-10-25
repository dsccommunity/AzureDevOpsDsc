Function Get-VstsServerApiUri{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ValidateScript({Test-VstsOrganizationName -VstsOrganizationName $_ -IsValid})]
    [Alias('OrganizationName')]
    [string]$VstsOrganizationName
  )

  [string]$VstsServerUri = Get-VstsServerUri -VstsOrganizationName $VstsOrganizationName

  return $VstsServerUri + "_apis"
}