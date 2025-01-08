task PreLoad {

    # Write a script to check the PSModule Path and add the output/
    # folder to the PSModule Path

    # Get the output directory
    $RepositoryRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $outputDir = Join-Path -Path $RepositoryRoot -ChildPath 'output'
    $supportingModules = Join-Path -Path $RepositoryRoot -ChildPath 'output/AzureDevOpsDsc/0.0.1/Modules'

    # Test if the output and supporting modules directories exist in the PSModulePath
    if (-not $IsWindows) {
        $modulelist = ($env:PSModulePath -split ":")
        $delimiter = ":"
    } else {
        $modulelist = ($env:PSModulePath -split ";")
        $delimiter = ";"
    }

    # Check if the output directory is in the moduleList
    if ($moduleList -notcontains $outputDir) {
        $env:PSModulePath = "{0}{1}{2}" -f $env:PSModulePath, $delimiter, $outputDir
        Write-Host "Adding $outputDir to PSModulePath"
    }
    if ($moduleList -notcontains $supportingModules) {
        $env:PSModulePath = "{0}{1}{2}" -f $env:PSModulePath, $delimiter, $supportingModules
        Write-Host "Adding $supportingModules to PSModulePath"
    }

}
