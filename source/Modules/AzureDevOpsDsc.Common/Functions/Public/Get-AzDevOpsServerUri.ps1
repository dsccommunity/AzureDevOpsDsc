Function Get-AzDevOpsServerUri{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ValidateScript({Test-AzDevOpsOrganizationName -AzDevOpsOrganizationName $_ -IsValid})]
    [Alias('OrganizationName')]
    [string]$AzDevOpsOrganizationName

  )

  $AzDevOpsOrganizationName = $AzDevOpsOrganizationName.ToLower()

  [string]$AzDevOpsServerUri = "https://dev.azure.com/$AzDevOpsOrganizationName/"

  return $AzDevOpsServerUri
}
