<#
.SYNOPSIS
    This class represents an Azure DevOps DSC resource for managing Git permissions.

.DESCRIPTION
    The AzDoGitPermission class is a DSC resource that allows you to manage Git permissions in Azure DevOps. It inherits from the AzDevOpsDscResourceBase class and provides properties and methods for managing Git permissions.

.PARAMETER ProjectName
    Specifies the name of the Azure DevOps project.

.PARAMETER RepositoryName
    Specifies the name of the Git repository.

.PARAMETER isInherited
    Specifies whether the permissions are inherited from the parent repository. Default value is $true.

.PARAMETER PermissionsList
    Specifies the list of permissions to be set for the repository.

.NOTES
    This class is part of the AzureDevOpsDSC module.

.LINK
    https://github.com/dsccommunity/AzureDevOpsDsc

.EXAMPLE
    This example shows how to use the AzDoGitPermission class to manage Git permissions in Azure DevOps.

    Configuration Example {
        Import-DscResource -ModuleName AzureDevOpsDSC

        Node localhost {
            AzDoGitPermission GitPermission {
                ProjectName = 'MyProject'
                RepositoryName = 'MyRepository'
                PermissionsList = @('Read', 'Contribute')
                Ensure = 'Present'
            }
        }
    }

#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDoGitPermission : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty(Mandatory)]
    [Alias('Repository')]
    [System.String]$RepositoryName

    [DscProperty()]
    [Alias('Inherited')]
    [System.Boolean]$isInherited=$true

    [DscProperty()]
    [HashTable[]]$Permissions

    AzDoGitPermission()
    {
        $this.Construct()
    }

    [AzDoGitPermission] Get()
    {
        return [AzDoGitPermission]$($this.GetDscCurrentStateProperties())
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

        $properties.ProjectName           = $CurrentResourceObject.ProjectName
        $properties.RepositoryName        = $CurrentResourceObject.RepositoryName
        $properties.isInherited           = $CurrentResourceObject.isInherited
        $properties.Permissions           = $CurrentResourceObject.Permissions
        $properties.lookupResult          = $CurrentResourceObject.lookupResult
        $properties.Ensure                = $CurrentResourceObject.Ensure

        Write-Verbose "[AzDoGitPermission] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
