# DSC xAzDoGroupMember Resource

## Syntax

```PowerShell
xAzDoGroupMember [string] #ResourceName
{
    GroupName = [String]$GroupName # [ProjectName|OrganizationName]\GroupName
    # For GroupMember Syntax, refer to # GroupMembers Syntax
    [ GroupMembers = [String[]]$GroupMembers ]
}
```

### GroupMembers Syntax

``` PowerShell
{
    GroupMember = [String]$GroupMemberName # [ProjectName|OrganizationName]\GroupName
}
```

The following string represents the service accounts for the project collection in Azure DevOps Organization:

```text
[ProjectName|AZDOOrganizationName]\Project Collection Service Accounts
```

- __[ProjectName|AZDOOrganizationName]__: The AzDO Project or Organizational Name.
- __Project Collection Service Accounts__: The Group Member Name. This can be a Group Name, Service Principal Name or Service Principle.

#### Example

If your Azure DevOps Organization name is `MyOrg`, the string would look like:

```text
[MyOrg]\Project Collection Service Accounts
```

## Properties

Common Properties:

- __GroupName__: The name of the Azure DevOps group.
- __GroupMembers__: An array of members to be included in the Azure DevOps group.

## Additional Information

This resource is used to manage Azure DevOps group memberships using Desired State Configuration (DSC). It allows you to define the properties of an Azure DevOps group and ensures that the group is configured according to those properties.

## Examples

### Example 1: Sample Configuration for Azure DevOps Group using xAzDoGroupMember Resource

```PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        xAzDoGroupMember GroupExample {
            GroupName    = 'MySampleGroup'
            GroupMembers = @('user1@example.com', 'user2@example.com')
        }
    }
}

ExampleConfig
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose
```

### Example 2: Sample Configuration for Azure DevOps Group using Invoke-DSCResource

```PowerShell
# Return the current configuration for xAzDoGroupMember
$properties = @{
    GroupName    = 'MySampleGroup'
    GroupMembers = @('user1@example.com', 'user2@example.com')
}

Invoke-DSCResource -Name 'xAzDoGroupMember' -Method Get -Property $properties -ModuleName 'AzureDevOpsDsc'
```

### Example 3: Sample Configuration to remove/exclude an Azure DevOps Group using Invoke-DSCResource

```PowerShell
# Remove the Azure DevOps Group and ensure that it is not recreated.
$properties = @{
    GroupName    = 'MySampleGroup'
    Ensure       = 'Absent'
}

Invoke-DSCResource -Name 'xAzDoGroupMember' -Method Set -Property $properties -ModuleName 'AzureDevOpsDsc'
```

### Example 4: Sample Configuration using xAzDoDSCDatum

```YAML
parameters: {}

variables: {
  GroupName: SampleGroup,
  GroupMembers: ['user1@example.com', 'user2@example.com']   
}

resources:

  - name: Group
    type: AzureDevOpsDsc/xAzDoGroupMember
    properties:
      groupName: $GroupName
      groupMembers: $GroupMembers
```

## LCM Initialization

```PowerShell
$params = @{
    AzureDevopsOrganizationName = "SampleAzDoOrgName"
    ConfigurationDirectory      = "C:\Datum\DSCOutput\"
    ConfigurationUrl            = 'https://configuration-path'
    JITToken                    = 'SampleJITToken'
    Mode                        = 'Set'
    AuthenticationType          = 'ManagedIdentity'
    ReportPath                  = 'C:\Datum\DSCOutput\Reports'
}

.\Invoke-AZDOLCM.ps1 @params
```
