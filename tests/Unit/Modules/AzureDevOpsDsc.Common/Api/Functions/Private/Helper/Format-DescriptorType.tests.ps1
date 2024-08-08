Describe 'Format-DescriptorType' {

    It 'returns "Git Repositories" for DescriptorType "GitRepositories"' {
        $result = Format-DescriptorType -DescriptorType 'GitRepositories'
        $result | Should -Be 'Git Repositories'
    }

    It 'returns the same value for DescriptorType "APIServices"' {
        $result = Format-DescriptorType -DescriptorType 'APIServices'
        $result | Should -Be 'APIServices'
    }

    It 'returns the same value for DescriptorType "Webhooks"' {
        $result = Format-DescriptorType -DescriptorType 'Webhooks'
        $result | Should -Be 'Webhooks'
    }

    It 'returns the same value for an empty string' {
        $result = Format-DescriptorType -DescriptorType ''
        $result | Should -Be ''
    }

}

