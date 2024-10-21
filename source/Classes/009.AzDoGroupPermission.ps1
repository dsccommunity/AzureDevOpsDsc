<#
.SYNOPSIS
    This class represents a DSC resource for managing Azure DevOps project group permissions.

.DESCRIPTION
    The AzDoGroupPermission class is a DSC resource that allows you to manage permissions for a group in an Azure DevOps project.

.NOTES
    Author: Your Name
    Date:   Current Date

.LINK
    GitHub Repository: <link to the GitHub repository>

.PARAMETER GroupName
    The name of the group for which the permissions are being managed.

.PARAMETER ProjectName
    The name of the Azure DevOps project.

.PARAMETER isInherited
    Specifies whether the permissions are inherited from a parent group. Default value is $true.

.PARAMETER Permissions
    Specifies the permissions to be assigned to the group. This should be an array of hashtables, where each hashtable represents a permission.

.EXAMPLE
    This example shows how to use the AzDoGroupPermission resource to manage permissions for a group in an Azure DevOps project.

    Configuration Example {
        Import-DscResource -ModuleName AzDevOpsDsc

        Node localhost {
            AzDoGroupPermission GroupPermission {
                GroupName = 'MyGroup'
                ProjectName = 'MyProject'
                Permissions = @(
                    @{
                        Permission = 'Read'
                        Allow = $true
                    },
                    @{
                        Permission = 'Write'
                        Allow = $false
                    }
                )
            }
        }
    }

#>

# RESOURCE IS CURRENTLY DISABLED
#[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDoGroupPermission : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$GroupName

    [DscProperty()]
    [Alias('Inherited')]
    [System.Boolean]$isInherited=$true

    [DscProperty()]
    [HashTable[]]$Permissions

    AzDoGroupPermission()
    {
        $this.Construct()
    }

    [AzDoGroupPermission] Get()
    {
        return [AzDoGroupPermission]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
    }


    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Ensure = [Ensure]::Absent
        }

        # If the resource object is null, return the properties
        if ($null -eq $CurrentResourceObject)
        {
            return $properties
        }

        $properties.GroupName             = $CurrentResourceObject.GroupName
        $properties.isInherited           = $CurrentResourceObject.isInherited
        $properties.Permissions           = $CurrentResourceObject.Permissions
        $properties.lookupResult          = $CurrentResourceObject.lookupResult
        $properties.Ensure                = $CurrentResourceObject.Ensure

        Write-Verbose "[AzDoGroupPermission] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
