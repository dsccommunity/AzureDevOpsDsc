Function Get-VstsServerUri{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ValidateScript({Test-VstsOrganizationName -VstsOrganizationName $_ -IsValid})]
    [Alias('OrganizationName')]
    [string]$VstsOrganizationName

  )

  $VstsOrganizationName = $VstsOrganizationName.ToLower()

  [string]$VstsServerUri = "https://dev.azure.com/$VstsOrganizationName/"

  return $VstsServerUri
}