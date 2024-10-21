$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-AzDoGitPermission' {


    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzDoGitPermission.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')
        . (Get-ClassFilePath '002.LocalizedDataAzSerializationPatten')

        Mock -CommandName Get-CacheItem -MockWith { return @{ namespaceId = 'SampleNamespaceId' } }
        Mock -CommandName ConvertTo-ACLHashtable -MockWith { return 'SerializedACLs' }
        Mock -CommandName Set-AzDoPermission

        $ProjectName = 'TestProject'
        $RepositoryName = 'TestRepo'
        $isInherited = $true
        $Permissions = @(@{ User = 'TestUser'; Permission = 'Allow' })
        $LookupResult = @{ propertiesChanged = 'someValue' }
        $Ensure = [Ensure]::Present

        $params = @{
            ProjectName = $ProjectName
            RepositoryName = $RepositoryName
            isInherited = $isInherited
            Permissions = $Permissions
            LookupResult = $LookupResult
            Ensure = $Ensure
        }

        $Global:DSCAZDO_OrganizationName = 'TestOrg'

    }

    BeforeEach {

        Mock Get-CacheItem -MockWith {
            return @{
                namespaceId = 'SampleNamespaceId'
            }
        }
        Mock ConvertTo-ACLHashtable -MockWith {
            return 'SerializedACLs'
        }
        Mock Set-AzDoPermission -MockWith {
            return $null
        }

    }

    It 'Calls Get-CacheItem with the correct parameters for security namespace' {
        Set-AzDoGitPermission @params
        Assert-MockCalled Get-CacheItem -Exactly 1 -ParameterFilter { ($Key -eq 'Git Repositories') -and ($Type -eq 'SecurityNamespaces') }
    }

    It 'Calls Get-CacheItem with the correct parameters for the project' {
        Set-AzDoGitPermission @params
        Assert-MockCalled Get-CacheItem -Exactly 1 -ParameterFilter { ($Key -eq $ProjectName) -and ($Type -eq 'LiveProjects') }
    }

    It 'Calls Set-AzDoPermission with the correct parameters' {
        Set-AzDoGitPermission @params
        Assert-MockCalled Set-AzDoPermission -Exactly 1 -ParameterFilter {
            ($OrganizationName -eq 'TestOrg') -and
            ($SecurityNamespaceID -eq 'SampleNamespaceId') -and
            ($SerializedACLs -eq 'SerializedACLs')
        }
    }

    It 'Serializes ACLs using ConvertTo-ACLHashtable with correct parameters' {
        Set-AzDoGitPermission @params
        Assert-MockCalled ConvertTo-ACLHashtable -Exactly 1 -ParameterFilter {
            $ReferenceACLs -eq 'someValue'
        }
    }

    It 'writes an error if Get-CacheItem is null' {

        Mock Get-CacheItem -MockWith { return $null }
        Mock Write-Error -Verifiable

        Set-AzDoGitPermission @params
        Assert-VerifiableMock
    }

}
