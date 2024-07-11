# Requires -Module Pester -Version 5.0.0
# Requires -Module DscResource.Common

# Test if the class is defined
if ($Global:ClassesLoaded -eq $null)
{
    # Attempt to find the root of the repository
    $RepositoryRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
    # Load the classes
    $preInitialize = Get-ChildItem -Path "$RepositoryRoot" -Recurse -Filter '*.ps1' | Where-Object { $_.Name -eq 'Classes.BeforeAll.ps1' }
    . $preInitialize.FullName -RepositoryPath $RepositoryRoot
}

Describe 'xAzDevOpsProject' {
    # Mocking AzDevOpsDscResourceBase class since it's not provided
    Class AzDevOpsDscResourceBase {
        [String]$Pat
        [String]$ApiUri
        [String]$Ensure
        [PSObject] GetDscCurrentStateProperties() { return $null }
    }

    Context 'Constructor' {
        It 'should initialize properties correctly when given valid parameters' {
            $project = [xAzDevOpsProject]::new()
            $project.ProjectId = "12345"
            $project.ProjectName = "TestProject"
            $project.ProjectDescription = "This is a test project"
            $project.SourceControlType = "Git"

            $project.ProjectId | Should -Be "12345"
            $project.ProjectName | Should -Be "TestProject"
            $project.ProjectDescription | Should -Be "This is a test project"
            $project.SourceControlType | Should -Be "Git"
        }
    }

    Context 'GetDscResourcePropertyNamesWithNoSetSupport Method' {
        It 'should return SourceControlType as property with no set support' {
            $project = [xAzDevOpsProject]::new()
            $result = $project.GetDscResourcePropertyNamesWithNoSetSupport()

            $result | Should -Contain "SourceControlType"
        }
    }

    Context 'GetDscCurrentStateProperties Method' {

        It 'should return correct properties when CurrentResourceObject is not null' {
            $project = [xAzDevOpsProject]::new()
            $currentResourceObject = [PSCustomObject]@{
                id = "12345"
                name = "TestProject"
                description = "This is a test project"
                capabilities = @{
                    versioncontrol = @{
                        sourceControlType = "Git"
                    }
                }
            }

            $result = $project.GetDscCurrentStateProperties($currentResourceObject)

            $result.ProjectId | Should -Be "12345"
            $result.ProjectName | Should -Be "TestProject"
            $result.ProjectDescription | Should -Be "This is a test project"
            $result.SourceControlType | Should -Be "Git"
            $result.Ensure | Should -Be "Present"
        }
    }
}
