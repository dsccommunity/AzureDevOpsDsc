using module ..\..\Enums\RequiredAction\RequiredAction.psm1
using module ..\..\Classes\DscResourceBase\DscResourceBase.psm1

$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath


class AzDevOpsApiDscResourceBase : DscResourceBase
{
    [System.String]$ResourceName = $this.GetResourceName()

    hidden [System.String]GetResourceName()
    {
        # Assumes a naming convention is followed between the DSC
        # resource name and the name of the resource within the API
        return $this.GetType().ToString().Replace('DSC_AzDevOps','')
    }



    <#
        .NOTES
            When creating an object via the Azure DevOps API, the ID (if provided) is ignored
            and Azure DevOps creates/generates the Id (a GUID) which can then be used for the
            object.

            As a result, only existing resources from the API will have a ResourceId and new
            resources to be created via the API do not need one providing.
    #>
    [System.String]$ResourceId = $this.GetResourceId()
    [System.String]$ResourceIdPropertyName = $this.GetResourceIdPropertyName()

    hidden [System.String]GetResourceId()
    {
        return $this."$($this.ResourceIdPropertyName)"
    }

    hidden [System.String]GetResourceIdPropertyName()
    {
        return "$($this.ResourceName)Id"
    }



    <#
        .NOTES
            When creating an object via the Azure DevOps API, the 'Key' of the object will be
            another, alternate, unique key/identifier to the 'ResourceId' but this will be
            specific to the resource.

            This 'Key' can be used to determine an 'Id' of a new resource that has been added.
    #>
    [System.String]$ResourceKey = $this.GetResourceKey()
    [System.String]$ResourceKeyPropertyName = $this.GetResourceKeyPropertyName()

    hidden [System.String]GetResourceKey()
    {
        [System.String]$keyPropertyName = $this.ResourceKeyPropertyName

        if ([System.String]::IsNullOrWhiteSpace($keyPropertyName))
        {
            return $null
        }

        return $this."$keyPropertyName"
    }

    hidden [System.String]GetResourceKeyPropertyName()
    {
        # Use same property as the DSC Resource 'Key'
        return $this.GetDscResourceKeyPropertyName()
    }



    hidden [System.String]GetResourceFunctionName([RequiredAction]$RequiredAction)
    {
        if ($RequiredAction -in @(
                [RequiredAction]::Get,
                [RequiredAction]::New,
                [RequiredAction]::Set,
                [RequiredAction]::Remove,
                [RequiredAction]::Test))
        {
            return "$($RequiredAction)-AzDevOps$($this.ResourceName)"
        }

        return $null
    }

}
