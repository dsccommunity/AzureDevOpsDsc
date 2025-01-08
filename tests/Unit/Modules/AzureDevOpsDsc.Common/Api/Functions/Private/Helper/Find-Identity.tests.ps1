$currentFile = $MyInvocation.MyCommand.Path

# Unit Tests for Find-Identity function
Describe 'Find-Identity Function Tests' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Find-Identity.tests.ps1"
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mock Get-CacheObject to return test data
        Mock -CommandName Get-CacheObject -MockWith {
            param (
                [string]$CacheType
            )

            switch ($CacheType)
            {
                'LiveGroups' {
                    return @{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'groupDescriptor'; id = 'groupId'; originId = 'groupOrigin'; principalName = 'groupPrincipal'; displayName = 'groupDisplay' } } }
                }
                'LiveUsers' {
                    return @{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'userDescriptor'; id = 'userId'; originId = 'userOrigin'; principalName = 'userPrincipal'; displayName = 'userDisplay' } } }
                }
                'LiveServicePrinciples' {
                    return @{ value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'spDescriptor'; id = 'spId'; originId = 'spOrigin'; principalName = 'spPrincipal'; displayName = 'spDisplay' } } }
                }
            }
        }

        # Mock Get-DevOpsDescriptorIdentity to return test identity
        Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
            param (
                [string]$OrganizationName,
                [string]$Descriptor
            )

            return [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'apiDescriptor'; id = 'apiId'; originId = 'apiOrigin'; principalName = 'apiPrincipal'; displayName = 'apiDisplay' } }
        }

        Mock Write-Verbose
        Mock Write-Warning

    }

    Context "when searching the existing cache" {

        It 'Should return group identity for valid group descriptor' {
            $result = Find-Identity -Name 'groupDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'

            $result.value.ACLIdentity.descriptor | Should -Be 'groupDescriptor'
        }

        It 'Should return user identity for valid user descriptor' {
            $result = Find-Identity -Name 'userDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'

            $result.value.ACLIdentity.descriptor | Should -Be 'userDescriptor'
        }

        It 'Should return null for multiple identities with the same name' {
            Mock -CommandName Get-CacheObject -MockWith {
                @{
                    value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'duplicateDescriptor'; id = 'duplicateId' } }
                }, @{
                    value = [PSCustomObject]@{ ACLIdentity = [PSCustomObject]@{ descriptor = 'duplicateDescriptor'; id = 'duplicateId' } }
                }
            }

            $result = Find-Identity -Name 'duplicateDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'

            $result | Should -BeNullOrEmpty
        }

    }

    Context "when searching the cache with a known name" {

        BeforeAll {

            $params = @(
                @{
                    SearchType = 'descriptor'
                }
                @{
                    SearchType = 'descriptorId'
                }
                @{
                    SearchType = 'originId'
                }
                @{
                    SearchType = 'principalName'
                }
                @{
                    SearchType = 'displayName'
                }
            )

        }

        it 'Should write a terminating error when the SearchType is incorrect' {
            { Find-Identity -Name 'groupDescriptor' -OrganizationName 'TestOrg' -SearchType 'invalidType' } | Should -Throw
        }

        it 'Should return a value for the search-type <SearchType>' -TestCases $params {
            param (
                [string]$SearchType
            )

            $result = Find-Identity -Name 'groupDescriptor' -OrganizationName 'TestOrg' -SearchType $SearchType
            $result | Should -Not -BeNullOrEmpty

        }

    }

    Context "when searching the API" {

        It 'Should return null for non-existent descriptor' {

            Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
                return $null
            }

            $result = Find-Identity -Name 'nonExistentDescriptor' -OrganizationName 'TestOrg' -SearchType 'descriptor'
            $result | Should -BeNullOrEmpty
        }

        It 'Should attempt to search the cache again using the ID this time' {
            Mock Write-Warning -Verifiable
            Mock Write-Verbose -Verifiable
            Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
                return @{
                    id = 'groupId'
                    descriptor = 'mockDescriptor'
                }
            }

            $result = Find-Identity -Name 'unknownName' -OrganizationName 'TestOrg' -SearchType 'descriptor'

            Assert-MockCalled Get-DevOpsDescriptorIdentity
            $result.value.ACLIdentity.descriptor | Should -Be 'groupDescriptor'
            Assert-VerifiableMock
        }

    }




}
