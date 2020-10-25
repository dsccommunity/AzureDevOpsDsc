function Get-AzDevOpsServerApiUri{

  [CmdletBinding()]
  [OutputType([string])]
  param(

    [ValidateScript({Test-AzDevOpsOrganizationName -AzDevOpsOrganizationName $_ -IsValid})]
    [Alias('OrganizationName')]
    [string]$AzDevOpsOrganizationName
  )

  [string]$AzDevOpsServerUri = Get-AzDevOpsServerUri -AzDevOpsOrganizationName $AzDevOpsOrganizationName

  return $AzDevOpsServerUri + "_apis"
}
