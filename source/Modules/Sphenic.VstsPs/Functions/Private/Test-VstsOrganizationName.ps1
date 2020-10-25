Function Test-VstsOrganizationName{

  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Alias('OrganizationName')]
    [string]$VstsOrganizationName,

    [switch]$IsValid
  )

  If(!$IsValid){
    throw "The '-IsValid' switch must be used when calling 'Test-VstsOrganizationName'."
    return
  }

  If([string]::IsNullOrWhiteSpace($VstsOrganizationName)){
    return $false
  }
  ElseIf($VstsOrganizationName.Contains(' ') -or
         $VstsOrganizationName.Contains('%')){
    return $false
  }

  return $true
}

