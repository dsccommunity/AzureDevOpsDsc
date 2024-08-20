$currentFile = $MyInvocation.MyCommand.Path

Describe "New-DevOpsGroupMember Tests" {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "3.0-preview" }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{
                success = $true
                message = "Member added successfully"
            }
        }
        Mock -CommandName Write-Verbose
        Mock -CommandName Write-Error
    }

    Context "When adding a new member to a DevOps group" {

        It "should call Get-AzDevOpsApiVersion if ApiVersion is not provided" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }

        It "should not call Get-AzDevOpsApiVersion if ApiVersion is provided" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiVersion = "6.0"
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri -ApiVersion $ApiVersion

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0
        }

        It "should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiVersion = "6.0"
            $ApiUri = "https://dev.azure.com/organization"
            $expectedUri = "$ApiUri/_apis/graph/memberships/$($MemberIdentity.descriptor)/$($GroupIdentity.descriptor)?api-version=$ApiVersion"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri -ApiVersion $ApiVersion

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
                $ApiUri -eq $expectedUri -and
                $Method -eq "PUT"
            }
        }

        It "should write a verbose message if member is added successfully" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled Write-Verbose -Times 3
        }

        It "should write an error message if adding a member to the group fails" {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                throw "API call failed"
            }

            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled Write-Error -Exactly 1
        }
    }
}
