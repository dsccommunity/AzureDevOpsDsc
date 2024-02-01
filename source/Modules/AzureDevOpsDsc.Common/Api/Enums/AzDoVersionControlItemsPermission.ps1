<#
.SYNOPSIS
    Enumeration of permissions for version control items in Azure DevOps.

.DESCRIPTION
    The AzDoVersionControlItemsPermission enumeration defines the different permissions that can be assigned to version control items in Azure DevOps.

    The available permissions are:
    - Read: Read permission for the version control item.
    - PendChange: Permission to pend changes to the version control item.
    - Checkin: Permission to check in changes to the version control item.
    - Label: Permission to label the version control item.
    - Lock: Permission to lock the version control item.
    - ReviseOther: Permission to revise other users' changes to the version control item.
    - UnlockOther: Permission to unlock other users' changes to the version control item.
    - UndoOther: Permission to undo other users' changes to the version control item.
    - LabelOther: Permission to label the version control item for other users.
    - AdminProjectRights: Permission to administer project-level rights for the version control item.
    - CheckinOther: Permission to check in changes to the version control item for other users.
    - Merge: Permission to merge changes to the version control item.
    - ManageBranch: Permission to manage branches for the version control item.

    Source: https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#project-level-namespaces-and-permissions

Manages permissions for a Team Foundation Version Control (TFVC) repository. There is only one TFVC repository for a project. You can manage these permissions through the Project settings, Repositories administrative interface.

ID: a39371cf-0841-4c16-bbd3-276e341bc052

.NOTES
    Author: Your Name
    Date: Current Date
#>

enum AzDoVersionControlItemsPermission {
    Read = 1
    PendChange = 2
    Checkin = 4
    Label = 8
    Lock = 16
    ReviseOther = 32
    UnlockOther = 64
    UndoOther = 128
    LabelOther = 256
    AdminProjectRights = 512
    CheckinOther = 1024
    Merge = 2048
    ManageBranch = 4096
}
