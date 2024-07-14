
Describe 'Format-DescriptorType' {
    It 'should return "Git Repositories" when passed "GitRepositories"' {
        $result = Format-DescriptorType -DescriptorType "GitRepositories"
        $result | Should -Be "Git Repositories"
    }

    It 'should return the same value when passed a different string' {
        $value = "SomeOtherDescriptor"
        $result = Format-DescriptorType -DescriptorType $value
        $result | Should -Be $value
    }

    It 'should throw an error when DescriptorType is not provided' {
        { Format-DescriptorType } | Should -Throw
    }
}

