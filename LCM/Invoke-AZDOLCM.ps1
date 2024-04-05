<#
param(

    [Parameter(Mandatory)]
    [String]$DSCDirectory,

    [Parameter(Mandatory)]
    [String]$DSCResourcesPath,

    [Parameter()]
    [String[]]$ResourceNames,

    [Parameter()]
    [ValidateSet('Get', 'Set')]
    [String]$ResourceMethods

)
#>


# Define the Report Path
#$ReportPath = Join-Path -Path $DSCDirectory -ChildPath "Reports"

# Load the module

#$VerbosePreference = "Continue"
#Wait-Debugger
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1' -Verbose

#
# Create an Object Containing the Organization Name.

$moduleSettingsPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "ModuleSettings.clixml"

$objectSettings = @{
    OrganizationName = "akkodistestorg"
}

$objectSettings | Export-Clixml -LiteralPath $moduleSettingsPath

# Initalize the Cache
'LiveGroups', 'LiveProjects', 'Project','Team', 'Group', 'SecurityDescriptor' | ForEach-Object {
    Initialize-CacheObject -CacheType $_
}

# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName $objectSettings.OrganizationName -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName -Verbose
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName -Verbose

#
# Locate the Configuration and load into Memory

$Configuration = Get-Configuration -DSCDirectory $DSCDirectory -DSCResourcesPath $DSCResourcesPath
Get-ChildItem -LiteralPath $Configuration -Recurse -Filter '*.yaml' | ForEach-Object {
    . $_.FullName
}

#
# Enumerate the Resources to be invoked based on the DependsOn Property.

$ResourceWithDependsOn, $ResourcesWithoutDependsOn = $ResourceConfiguration.Where({ $_.DependsOn -ne $null }, 'Split')

#
# Format the DependsOn Property by ensuring the Resource parent is before the child.

$ResourceConfiguration = [System.Collections.ArrayList]::New()

# Enumerate the Resources with DependsOn Property
$ResourceWithDependsOn | ForEach-Object {
    $ResourceObject = $_
    # Get the DependsOn Property
    $DependsOn = $_.DependsOn
    # Locate the index position of the Resource within ResourceConfiguration. If there are multiple resources with the same name, sort by the lowest index number.
    $ResourceIndex = 0 .. $ResourceConfiguration.Count | Where-Object { $ResourceConfiguration[$_].Name -eq $DependsOn } | Sort-Object | Select-Object -First 1
    # If the Resource is not found, add it to the end of the list.
    if ($ResourceIndex -eq $null) {
        $ResourceConfiguration.Add($_)
    }
    # If the Resource is found, insert it before the Resource.
    else {
        $ResourceConfiguration.Insert($ResourceObject, $_)
    }
}

#
# Add ResourcesWithoutDependsOn to the top of the list.

$ResourcesWithoutDependsOn | ForEach-Object {
    $ResourceConfiguration.Insert(0, $_)
}

#
# Invoke the Resources

ForEach($Resource in $ResourceConfiguration) {

    $ResourceName = $Resource.Name
    $ResourceProperties = $Resource.Properties

    #
    # Test the state to see if the resource is in spec

    $params = @{
        Name = $ResourceName
        Method = 'Test'
        Property = $ResourceProperties
        ModuleName = 'AzureDevOpsDsc'
    }

    $dscState = Invoke-DscResource @params

    #
    # If the resource is not in spec, set the resource to the desired state.

    if ($dscState.InDesiredState) {  continue }

    #
    # Update the parameters according to the Parameters the resource to the desired state.

    $params.Method = $ResourceMethods

    # Invoke the Resource
    $dscResult = Invoke-DscResource @params

    # If the ResourceMethod is 'Get', return the output, otherwise return $null.
    return (($ResourceMethods -eq 'Get') ? $dscResult : $null)

}
