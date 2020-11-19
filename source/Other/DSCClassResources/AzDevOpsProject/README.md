# Description

The `AzDevOpsProject`, DSC Resource sets `Project` resources within Azure DevOps
Server/Services.

This DSC Resource uses both `ProjectId` and `ProjectName` as forms of unique
identification of a `Project` although the `ProjectName` must be unique across 
all projects within the `Organization` (in Azure DevOps Services) or the
`Collection` (in Azure DevOps Server).

Azure DevOps generates the `ProjectId` when creating the `Project` resource so,
typically, `ProjectId` will not be assigned a property value within a
configuration but this property can be referenced by other DSC Resources defined
in a configuration.

>**Note:** This DSC Resource does *not* support the changes to the type of
> source control used by a `Project` (defined by the `SourceControlType`
> property) - The Azure DevOps REST API does not currently support this
> operation.
>
> Any attempt to update an existing `Project` created with one
> `SourceControlType` (e.g. `Git`) to another (e.g. `Tfvc`) will throw an
> exception.

## Permissions

* Any Personal Access Token (PAT) being used to manage this `AzDevOpsProject`,
  DSC Resource must have the following permissions configured in Azure DevOps:
  * **Project and Team** (Read, write and manage)

* Information on creating a Personal Access Token (PAT) can be found [here](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
(as part of the [Azure DevOps documentation](https://docs.microsoft.com/en-us/azure/devops/?view=azure-devops)
maintained by Microsoft).

## Requirements

There are no specific requirements (in addition to the required permissions
within Azure DevOps) for this DSC Resource.

## Examples

Examples of usage of the `AzDevOpsProject`, DSC Resource within a DSC
configuration can be found [here](../../../Examples/Resources/AzDevOpsProject).

## Related Commands

The embedded, `AzureDevOpsDsc.Common`, module exports the following commands
which relate to this DSC Resource:

* `Get-AzDevOpsProject`
* `Set-AzDevOpsProject`
* `Remove-AzDevOpsProject`

The DSC Resource uses these commands directly so they can be considered tested,
stable, maintained and supported as part of the `AzureDevOpsDsc` module.

## Azure DevOps Services REST API

The overview page (within the [Azure DevOps Services REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops/) dcoumentation maintained by Microsoft) for the Azure DevOps, `Project`
resource behind this DSC Resource is [here](https://docs.microsoft.com/en-us/rest/api/azure/devops/core/projects).

## Known issues

All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/AzureDevOpsDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+AzDevOpsProject).
