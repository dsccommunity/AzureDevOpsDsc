@{
    PSDependOptions                = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                    = 'latest'
    PSScriptAnalyzer               = 'latest'
    Pester                         = '4.10.1'
    Plaster                        = 'latest'
    ModuleBuilder                  = 'latest'
    ChangelogManagement            = 'latest'
    Sampler                        = 'latest'
    'Sampler.GitHubTasks'          = 'latest'
    MarkdownLinkCheck              = 'latest'
    'DscResource.Test'             = 'latest'
    xDscResourceDesigner           = 'latest'
    'DscResource.Common'           = 'latest'

    'DscResource.AnalyzerRules'    = @{
        Version    = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
    'Indented.ScriptAnalyzerRules' = 'latest'

    # Prerequisite modules for documentation.
    'DscResource.DocGenerator'     = @{
        Version    = 'latest'
        Parameters = @{
            AllowPrerelease = $true
        }
    }
    PlatyPS                        = 'latest'

    # Prerequisites modules needed for examples or integration tests
    PSDscResources                 = '2.12.0.0'
}
