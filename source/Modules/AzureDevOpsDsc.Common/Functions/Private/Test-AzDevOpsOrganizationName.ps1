function Test-AzDevOpsOrganizationName{

  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Alias('OrganizationName')]
    [string]$AzDevOpsOrganizationName,

    [switch]$IsValid
  )

  If(!$IsValid){
    throw "The '-IsValid' switch must be used when calling 'Test-AzDevOpsOrganizationName'."
    return
  }

  If([string]::IsNullOrWhiteSpace($AzDevOpsOrganizationName)){
    return $false
  }
  ElseIf($AzDevOpsOrganizationName.Contains(' ') -or
         $AzDevOpsOrganizationName.Contains('%')){
    return $false
  }

  return $true
}

