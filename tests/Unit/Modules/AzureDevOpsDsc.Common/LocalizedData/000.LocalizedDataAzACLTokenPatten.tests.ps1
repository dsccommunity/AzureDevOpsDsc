$currentFile = $MyInvocation.MyCommand.Path

# Define tests
Describe "Testing LocalizedDataAzACLTokenPattern regex patterns" {

    BeforeAll {
        $source = Get-FunctionItem '000.LocalizedDataAzACLTokenPatten.ps1'

        . $source.FullName

    }

    It "OrganizationGit should match 'repoV2'" {
        'repoV2' -match $LocalizedDataAzACLTokenPatten.OrganizationGit | Should -BeTrue
    }

    It "GitProject should match 'repoV2/Project123'" {
        'repoV2/Project123' -match $LocalizedDataAzACLTokenPatten.GitProject | Should -BeTrue
    }

    It "GitRepository should match 'repoV2/Project123/Repo456'" {
        'repoV2/Project123/Repo456' -match $LocalizedDataAzACLTokenPatten.GitRepository | Should -BeTrue
    }

    It "GitBranch should match 'repoV2/Project123/Repo456/refs/heads/main'" {
        'repoV2/Project123/Repo456/refs/heads/main' -match $LocalizedDataAzACLTokenPatten.GitBranch | Should -BeTrue
    }

    It "GroupPermission should match 'Project123\Group456'" {
        'Project123\Group456' -match $LocalizedDataAzACLTokenPatten.GroupPermission | Should -BeTrue
    }

    It "ResourcePermission should match 'Project123'" {
        'Project123' -match $LocalizedDataAzACLTokenPatten.ResourcePermission | Should -BeTrue
    }

    # Negative tests
    It "OrganizationGit should not match 'repoV3'" {
        'repoV3' -match $LocalizedDataAzACLTokenPatten.OrganizationGit | Should -BeFalse
    }

    It "GitProject should not match 'repoV2/'" {
        'repoV2/' -match $LocalizedDataAzACLTokenPatten.GitProject | Should -BeFalse
    }

    It "GitRepository should not match 'repoV2/Project123/'" {
        'repoV2/Project123/' -match $LocalizedDataAzACLTokenPatten.GitRepository | Should -BeFalse
    }

    It "GitBranch should not match 'repoV2/Project123/Repo456/branches/main'" {
        'repoV2/Project123/Repo456/branches/main' -match $LocalizedDataAzACLTokenPatten.GitBranch | Should -BeFalse
    }

    It "GroupPermission should not match 'Project123'" {
        'Project123' -match $LocalizedDataAzACLTokenPatten.GroupPermission | Should -BeFalse
    }

    It "ResourcePermission should not match 'Project123\Extra'" {
        'Project123\Extra' -match $LocalizedDataAzACLTokenPatten.ResourcePermission | Should -BeFalse
    }
}
