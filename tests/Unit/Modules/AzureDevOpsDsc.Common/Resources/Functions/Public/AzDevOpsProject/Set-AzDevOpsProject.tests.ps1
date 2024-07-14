
# Define the function mock and the tests for Set-AzDevOpsProject
function Test-AzDevOpsApiUri {
    param($ApiUri)
    return $true
}

function Test-AzDevOpsPat {
    param($Pat)
    return $true
}

function Test-AzDevOpsProjectId {
    param($ProjectId)
    return $true
}

function Test-AzDevOpsProjectName {
    param($ProjectName)
    return $true
}

function Test-AzDevOpsProjectDescription {
    param($ProjectDescription)
    return $true
}

function Set-AzDevOpsApiResource {
    param($ApiUri, $Pat, $ResourceName, $ResourceId, $Resource, $Force, $Wait)
    return $null
}

function Get-AzDevOpsProject {
    param($ApiUri, $Pat, $ProjectId, $ProjectName)
    return @{
        "id" = $ProjectId
        "name" = $ProjectName
        "description" = "some description"
    }
}

Describe 'Set-AzDevOpsProject' {
    Mock -ModuleName ModuleName -CommandName Test-AzDevOpsApiUri -MockWith { $true }
    Mock -ModuleName ModuleName -CommandName Test-AzDevOpsPat -MockWith { $true }
    Mock -ModuleName ModuleName -CommandName Test-AzDevOpsProjectId -MockWith { $true }
    Mock -ModuleName ModuleName -CommandName Test-AzDevOpsProjectName -MockWith { $true }
    Mock -ModuleName ModuleName -CommandName Test-AzDevOpsProjectDescription -MockWith { $true }
    Mock -ModuleName ModuleName -CommandName Set-AzDevOpsApiResource -MockWith { $null }
    Mock -ModuleName ModuleName -CommandName Get-AzDevOpsProject -MockWith {
        param($ApiUri, $Pat, $ProjectId, $ProjectName)
        return @{
            "id" = $ProjectId
            "name" = $ProjectName
            "description" = "Updated description"
        }
    }

    It 'Should return the updated project details' {
        $result = Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                                      -Pat 'SomePAT' `
                                      -ProjectId 'SomeProjectId' `
                                      -ProjectName 'SomeProjectName' `
                                      -ProjectDescription 'SomeProjectDescription' `
                                      -Force
        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be 'SomeProjectId'
        $result.name | Should -Be 'SomeProjectName'
        $result.description | Should -Be 'Updated description'
    }

    It 'Should call Test-AzDevOpsApiUri' {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                            -Pat 'SomePAT' `
                            -ProjectId 'SomeProjectId' `
                            -ProjectName 'SomeProjectName' `
                            -ProjectDescription 'SomeProjectDescription' `
                            -Force

        Assert-MockCalled Test-AzDevOpsApiUri -Exactly 1 -Scope It
    }

    It 'Should call Test-AzDevOpsPat' {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                            -Pat 'SomePAT' `
                            -ProjectId 'SomeProjectId' `
                            -ProjectName 'SomeProjectName' `
                            -ProjectDescription 'SomeProjectDescription' `
                            -Force

        Assert-MockCalled Test-AzDevOpsPat -Exactly 1 -Scope It
    }

    It 'Should call Test-AzDevOpsProjectId' {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                            -Pat 'SomePAT' `
                            -ProjectId 'SomeProjectId' `
                            -ProjectName 'SomeProjectName' `
                            -ProjectDescription 'SomeProjectDescription' `
                            -Force

        Assert-MockCalled Test-AzDevOpsProjectId -Exactly 1 -Scope It
    }

    It 'Should call Set-AzDevOpsApiResource' {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                            -Pat 'SomePAT' `
                            -ProjectId 'SomeProjectId' `
                            -ProjectName 'SomeProjectName' `
                            -ProjectDescription 'SomeProjectDescription' `
                            -Force

        Assert-MockCalled Set-AzDevOpsApiResource -Exactly 1 -Scope It
    }

    It 'Should call Get-AzDevOpsProject' {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' `
                            -Pat 'SomePAT' `
                            -ProjectId 'SomeProjectId' `
                            -ProjectName 'SomeProjectName' `
                            -ProjectDescription 'SomeProjectDescription' `
                            -Force

        Assert-MockCalled Get-AzDevOpsProject -Exactly 1 -Scope It
    }
}

