@{
    Gallery                                    = 'PSGallery'
    AllowPrerelease                            = $false
    WithYAML                                   = $true # Will also bootstrap PowerShell-Yaml to read other config files

    #UseModuleFast = $true
    #ModuleFastVersion = '0.1.2'
    #ModuleFastBleedingEdge = $true

    UsePSResourceGet                           = $true
    #PSResourceGetVersion = '1.0.1'

    UsePowerShellGetCompatibilityModule        = $true
    UsePowerShellGetCompatibilityModuleVersion = '3.0.23-beta23'
}
