function Test-AzDevOpsOrganizationName{

  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Alias('OrganizationName')]
    [string]$AzDevOpsOrganizationName,

    [switch]$IsValid
  )

  if(!$IsValid){
    throw "The '-IsValid' switch must be used when calling 'Test-AzDevOpsOrganizationName'."
    return
  }

  if([string]::IsNullOrWhiteSpace($AzDevOpsOrganizationName)){
    return $false
  }
  elseIf($AzDevOpsOrganizationName.Contains(' ') -or
         $AzDevOpsOrganizationName.Contains('%')){
    return $false
  }

  return $true
}

