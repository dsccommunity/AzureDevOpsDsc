# Source: https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#project-level-namespaces-and-permissions

<#
.SYNOPSIS
Enum representing the permissions available for Azure DevOps projects.

.DESCRIPTION
The AzDoProjectPermission enum represents the various permissions that can be assigned to users or groups at the project level in Azure DevOps. These permissions control what actions users can perform within a project.

The enum values are based on the Azure DevOps namespace reference documentation, which can be found at the following URL:
https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#project-level-namespaces-and-permissions

Manages Project-level permissions.
The AGILETOOLS_BACKLOG permission manages access to Azure Boards backlogs. This is an internal permission setting and shouldn't be changed.

Root token format: $PROJECT
Token to secure permissions for each project in your organization.
$PROJECT:vstfs:///Classification/TeamProject/PROJECT_ID.
Assume you have a project named Test Project 1.
You can get the project ID for this project by using the az devops project show command.
az devops project show --project "Test Project 1"
The command returns a project-id, for example, xxxxxxxx-a1de-4bc8-b751-188eea17c3ba.
Therefore, the token to secure project-related permissions for Test Project 1 is:
'$PROJECT:vstfs:///Classification/TeamProject/xxxxxxxx-a1de-4bc8-b751-188eea17c3ba'

ID: 52d39943-cb85-4d7f-8fa8-c6baac873819

.PARAMETER None
This enum does not accept any parameters.

.EXAMPLE
The following example demonstrates how to use the AzDoProjectPermission enum:

$permission = [AzDoProjectPermission]::GenericRead
if ($permission -band [AzDoProjectPermission]::GenericRead) {
    Write-Host "User has GenericRead permission"
}

#>
Enum AzDoProjectPermission {
    GenericRead = 1
    GenericWrite = 2
    Delete = 4
    PublishTestResults = 8
    AdministerBuild = 16
    StartBuild = 32
    EditBuildStatus = 64
    UpdateBuild = 128
    DeleteTestResults = 256
    ViewTestResults = 512
    ManageTestEnviroments = 1024
    ManageTestConfigurations = 2048
    WorkItemDelete = 4096
    WorkItemMove = 8192
    WorkItemPermanentDelete = 16384
    Rename = 32768
    ManageProperties = 65536
    ManageSystemProperties = 131072
    BypassPropertyCache = 262144
    BypassRules = 524288
    SupressNotifications = 1048576
    UpdateVisibility = 2097152
    ChangeProcess = 4194304
    AgileToolsBacklog = 8388608
    AgileToolsPlans = 16777216
}
