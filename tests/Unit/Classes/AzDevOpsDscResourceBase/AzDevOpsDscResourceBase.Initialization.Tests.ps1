using module ..\..\..\..\output\builtModule\AzureDevOpsDsc\0.2.0\AzureDevOpsDsc.psm1

# Initialize tests for module function 'Classes'
. $PSScriptRoot\..\Classes.TestInitialization.ps1

# Note: Use of this functionality seems to pre-load the module and classes which subsquent tests can use
#       which works around difficulty of referencing classes in 'source' directory when code coverage is
#       using the dynamically/build-defined, 'output' directory.
InModuleScope 'AzureDevOpsDsc' {

    $script:dscModuleName = 'AzureDevOpsDsc'
    $script:moduleVersion = $(Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1).Version

}
