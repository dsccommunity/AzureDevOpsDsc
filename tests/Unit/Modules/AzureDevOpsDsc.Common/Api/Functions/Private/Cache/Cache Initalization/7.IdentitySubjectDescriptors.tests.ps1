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

        Mock -CommandName Get-CacheObject -MockWith {
            switch ($args[0]) {
                'LiveGroups' { @{} }
                'LiveUsers' { @{} }
                'LiveServicePrinciples' { @{} }
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
        Should -InvokeCommand -CommandName Get-CacheObject
        Should -InvokeCommand -CommandName Get-DevOpsDescriptorIdentity
        Should -InvokeCommand -CommandName Add-CacheItem
        Should -InvokeCommand -CommandName Export-CacheObject
    }

    It "should use OrganizationName parameter if provided" {
        $result = AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName 'testOrg'
        Should -InvokeCommand -CommandName Get-CacheObject
        Should -InvokeCommand -CommandName Get-DevOpsDescriptorIdentity
        Should -InvokeCommand -CommandName Add-CacheItem
        Should -InvokeCommand -CommandName Export-CacheObject
    }

    It "should call Get-CacheObject for each cache type" {
        $result = AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName 'testOrg'
        Should -InvokeCommand -CommandName Get-CacheObject -Times 3
    }

    It "should add members to each cache object" {
        $mockGroup = @{
            Key = 'mockKey'
            Value = [PSCustomObject]@{
                descriptor = 'mockDescriptorGroup'
            }
        }

        Mock -CommandName Get-CacheObject -MockWith { @{'mockGroup' = $mockGroup} }

        $result = AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName 'testOrg'

        Should -InvokeCommand -CommandName Get-DevOpsDescriptorIdentity -ParameterFilter {
            $_.SubjectDescriptor -eq 'mockDescriptorGroup'
        }

        $cacheItemArgs = @{
            Key = 'mockKey'
            Value = $mockGroup
            Type = 'LiveGroups'
            SuppressWarning = $true
        }

        Should -InvokeCommand -CommandName Add-CacheItem -ParameterFilter {
            $_.Key -eq $cacheItemArgs.Key -and
            $_.Value -eq $cacheItemArgs.Value -and
            $_.Type -eq $cacheItemArgs.Type -and
            $_.SuppressWarning -eq $cacheItemArgs.SuppressWarning
        }
    }
}
