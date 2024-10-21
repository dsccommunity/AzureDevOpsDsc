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

Describe 'AzDoOrganizationGroup' {
    # Mocking AzDevOpsDscResourceBase class since it's not provided
    Class AzDevOpsDscResourceBase {
        [void] Construct() {}
    }

    Context 'Constructor' {
        It 'should initialize properties correctly when given valid parameters' {
            $organizationGroup = [AzDoOrganizationGroup]::new()
            $organizationGroup.GroupName = "MyGroup"
            $organizationGroup.GroupDescription = "This is my group."

            $organizationGroup.GroupName | Should -Be "MyGroup"
            $organizationGroup.GroupDescription | Should -Be "This is my group."
        }
    }

    Context 'GetDscResourcePropertyNamesWithNoSetSupport Method' {
        It 'should return an empty array' {
            $organizationGroup = [AzDoOrganizationGroup]::new()

            $result = $organizationGroup.GetDscResourcePropertyNamesWithNoSetSupport()

            $result | Should -Be @()
        }
    }

    Context 'GetDscCurrentStateProperties Method' {
        It 'should return properties with Ensure set to Absent if CurrentResourceObject is null' {
            $organizationGroup = [AzDoOrganizationGroup]::new()

            $result = $organizationGroup.GetDscCurrentStateProperties($null)

            $result.Ensure | Should -Be 'Absent'
        }

        It 'should return current state properties from CurrentResourceObject' {
            $organizationGroup = [AzDoOrganizationGroup]::new()
            $currentResourceObject = [PSCustomObject]@{
                GroupName = "MyGroup"
                GroupDescription = "This is my group"
                Ensure = "Present"
                LookupResult = @{ Status = "Found" }
            }

            $result = $organizationGroup.GetDscCurrentStateProperties($currentResourceObject)

            $result.GroupName | Should -Be "MyGroup"
            $result.GroupDescription | Should -Be "This is my group"
            $result.Ensure | Should -Be "Present"
            $result.LookupResult.Status | Should -Be "Found"
        }
    }
}
