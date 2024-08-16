
Describe "New-DevOpsGroupMember Tests" {

    Mock Get-AzDevOpsApiVersion {
        return "3.0-preview"
    }

    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            success = $true
            message = "Member added successfully"
        }
    }

    Mock Write-Verbose
    Mock Write-Error

    Context "When adding a new member to a DevOps group" {

        It "should call Get-AzDevOpsApiVersion if ApiVersion is not provided" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1 -Scope It
        }

        It "should not call Get-AzDevOpsApiVersion if ApiVersion is provided" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiVersion = "6.0"
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri -ApiVersion $ApiVersion

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0 -Scope It
        }

        It "should call Invoke-AzDevOpsApiRestMethod with correct parameters" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiVersion = "6.0"
            $ApiUri = "https://dev.azure.com/organization"
            $expectedUri = "$ApiUri/_apis/graph/memberships/$($MemberIdentity.descriptor)/$($GroupIdentity.descriptor)?api-version=$ApiVersion"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri -ApiVersion $ApiVersion

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq $expectedUri -and $Method -eq "PUT"
            }
        }

        It "should write a verbose message if member is added successfully" {
            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled Write-Verbose -Exactly 3
        }

        It "should write an error message if adding a member to the group fails" {
            Mock Invoke-AzDevOpsApiRestMethod {
                throw "API call failed"
            }

            $GroupIdentity = [PSCustomObject]@{ descriptor = "group-descriptor" }
            $MemberIdentity = [PSCustomObject]@{ descriptor = "member-descriptor" }
            $ApiUri = "https://dev.azure.com/organization"

            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled Write-Error -Exactly 1 -Scope It
        }
    }
}

