Get-ChildItem -LiteralPath 'C:\Temp\AzureDevOpsDSC\source\Enum' -File | ForEach-Object {
    . $_.FullName
}
Get-ChildItem -LiteralPath 'C:\Temp\AzureDevOpsDSC\source\Classes' -File | ForEach-Object {
    # Read the file and remove [DscResource()] attribute
    $file = Get-Command $_.FullName
    # Remove [DscResource()] attribute
    $content = $file.ScriptContents -replace '\[DscResource\(\)\]', ''
    # Conver the string array into ScriptBlock
    $scriptBlock = [ScriptBlock]::Create($content)
    # Dot source the script block
    . $scriptBlock

}


Get-ChildItem -LiteralPath 'C:\Temp\AzureDevOpsDSC\source\Modules\AzureDevOpsDsc.Common\Resources\Functions' -Recurse -File | ForEach-Object {
    . $_.FullName
}
Get-ChildItem -LiteralPath 'C:\Temp\AzureDevOpsDSC\source\Modules\AzureDevOpsDsc.Common\Api' -Recurse -File | ForEach-Object {
    . $_.FullName
}

$ModuleRoot = 'C:\Temp\AzureDevOpsDSC\source\Modules\AzureDevOpsDsc.Common\'

# Initalize the Cache
'LiveGroups', 'LiveProjects', 'Project','Team', 'Group', 'SecurityDescriptor' | ForEach-Object {
    Initialize-CacheObject -CacheType $_
}

# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName "akkodistestorg" -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName -Verbose
