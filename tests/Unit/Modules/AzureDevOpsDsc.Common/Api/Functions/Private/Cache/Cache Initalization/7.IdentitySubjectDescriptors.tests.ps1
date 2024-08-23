$currentFile = $MyInvocation.MyCommand.Path

Describe "AzDoAPI_7_IdentitySubjectDescriptors" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath '7.IdentitySubjectDescriptors.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDoCacheObjects -MockWith {
            @('LiveGroups', 'LiveUsers', 'LiveServicePrinciples')
        }

        Mock -CommandName Get-CacheObject -MockWith {

            switch ($CacheType)
            {
                'LiveGroups' {
                    return (
                        [PSCustomObject]@{
                            Key = 'mockKey'
                            Value = @{
                                descriptor = 'mockDescriptorGroup'
                            }
                        }
                    )
                }
                'LiveUsers' {
                    return (
                        [PSCustomObject]@{
                            Key = 'mockKey'
                            Value = @{
                                descriptor = 'mockDescriptorUser'
                            }
                        }
                    )
                }
                'LiveServicePrinciples' {
                    return (
                        [PSCustomObject]@{
                            Key = 'mockKey'
                            Value = @{
                                descriptor = 'mockDescriptorServicePrinciple'
                            }
                        }
                    )
                 }
            }
        }

        Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
            @{
                id = 'mockId'
                descriptor = 'mockDescriptor'
                subjectDescriptor = 'mockSubjectDescriptor'
                providerDisplayName = 'mockProvider'
                isActive = $true
                isContainer = $false
            }
        }

        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'mockOrg'
    }

    It "should use a global variable if OrganizationName parameter is not provided" {


        $result = AzDoAPI_7_IdentitySubjectDescriptors

        Assert-MockCalled -CommandName Get-CacheObject
        Assert-MockCalled -CommandName Get-DevOpsDescriptorIdentity
        Assert-MockCalled -CommandName Add-CacheItem
        Assert-MockCalled -CommandName Export-CacheObject
    }

    It "should use OrganizationName parameter if provided" {
        $result = AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName 'testOrg'

        Assert-MockCalled -CommandName Get-CacheObject
        Assert-MockCalled -CommandName Get-DevOpsDescriptorIdentity
        Assert-MockCalled -CommandName Add-CacheItem
        Assert-MockCalled -CommandName Export-CacheObject
    }

    It "should call Get-CacheObject for each cache type" {
        $result = AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName 'testOrg'
        Assert-MockCalled -CommandName Get-CacheObject -Times 3
    }

    It "should add members to each cache object" {

        Mock -CommandName Get-DevOpsDescriptorIdentity -MockWith {
            @{
                id = 'mockId'
                descriptor = 'mockDescriptor'
                subjectDescriptor = 'mockSubjectDescriptor'
                providerDisplayName = 'mockProvider'
                isActive = $true
                isContainer = $false
            }
        }

        $mockGroup = @{
            Key = 'mockKey'
            Value = [PSCustomObject]@{
                descriptor = 'mockDescriptorGroup'
            }
        }

        $result = AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName 'testOrg'

        Assert-MockCalled -CommandName Get-DevOpsDescriptorIdentity -ParameterFilter {
            $SubjectDescriptor -eq 'mockDescriptorGroup'
        }

        $cacheItemArgs = @{
            Key = 'mockKey'
            Value = $mockGroup
            Type = 'LiveGroups'
            SuppressWarning = $true
        }

        Assert-MockCalled -CommandName Add-CacheItem -Times 1 -ParameterFilter {
            $Key -eq $cacheItemArgs.Key -and
            $Type -eq $cacheItemArgs.Type -and
            $SuppressWarning -eq $cacheItemArgs.SuppressWarning
        }

    }
}
