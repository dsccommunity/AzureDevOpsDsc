Describe "AzDoAPI_7_IdentitySubjectDescriptors Tests" {
    
    Mock -CommandName Get-CacheObject {
        switch ($args[1]) {
            'LiveGroups' { return @{} }
            'LiveUsers' { return @{} }
            'LiveServicePrinciples' { return @{} }
        }
    }

    Mock -CommandName Get-DevOpsDescriptorIdentity {
        return [PSCustomObject]@{
            id = 'test-id'
            descriptor = 'test-descriptor'
            subjectDescriptor = 'test-subjectDescriptor'
            providerDisplayName = 'test-providerDisplayName'
            isActive = $true
            isContainer = $false
        }
    }

    Mock -CommandName Add-CacheItem
    Mock -CommandName Export-CacheObject
    Mock -CommandName Write-Verbose

    Context "When OrganizationName is provided" {
        It "Should call Get-CacheObject and other dependent commands" {
            $OrganizationName = "TestOrganization"
            AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName $OrganizationName

            # Verifying Get-CacheObject calls
            (Get-CommandMock -CommandName Get-CacheObject).CallCount | Should -Be 3

            # Verifying Get-DevOpsDescriptorIdentity calls
            (Get-CommandMock -CommandName Get-DevOpsDescriptorIdentity).CallCount | Should -BeGreaterThan 0

            # Verifying Add-CacheItem calls
            (Get-CommandMock -CommandName Add-CacheItem).CallCount | Should -BeGreaterThan 0

            # Verifying Export-CacheObject calls
            (Get-CommandMock -CommandName Export-CacheObject -ParameterFilter { $CacheType -eq 'LiveGroups' }).CallCount | Should -Be 1
            (Get-CommandMock -CommandName Export-CacheObject -ParameterFilter { $CacheType -eq 'LiveUsers' }).CallCount | Should -Be 1
            (Get-CommandMock -CommandName Export-CacheObject -ParameterFilter { $CacheType -eq 'LiveServicePrinciples' }).CallCount | Should -Be 1

            # Verifying Write-Verbose calls
            (Get-CommandMock -CommandName Write-Verbose).CallCount | Should -BeGreaterThan 1
        }
    }

    Context "When OrganizationName is not provided" {
        It "Should use global variable for OrganizationName" {
            $Global:DSCAZDO_OrganizationName = "GlobalTestOrganization"

            AzDoAPI_7_IdentitySubjectDescriptors

            # Verifying Get-CacheObject calls
            (Get-CommandMock -CommandName Get-CacheObject).CallCount | Should -Be 3
        }
    }
}
