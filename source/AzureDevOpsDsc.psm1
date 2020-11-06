$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
$script:azureDevOpsDscServerModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Server'
$script:azureDevOpsDscServicesModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Services'
#$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DscResource.Common'

Import-Module -Name $script:azureDevOpsDscCommonModulePath
Import-Module -Name $script:azureDevOpsDscServerModulePath
Import-Module -Name $script:azureDevOpsDscServicesModulePath
#Import-Module -Name $script:dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'


enum Ensure
{
    Present
    Absent
}

enum RequiredAction
{
    None
    New
    Set
    Remove
    Error
}





class AzDevOpsApiResource
{
    [string]$ResourceName = $this.GetResourceName()

    hidden [string]GetResourceName()
    {
        # Assumes a naming convention is followed between the DSC
        # resource name and the name of the resource within the API
        return $this.GetType().ToString().Replace('DSC_AzDevOps','').Replace('AzDevOps','')
    }



    <#
        .NOTES
            When creating an object via the Azure DevOps API, the ID (if provided) is ignored
            and Azure DevOps creates/generates the Id (a GUID) which can then be used for the
            object.

            As a result, only existing resources from the API will have a ResourceId and new
            resources to be created via the API do not need one providing.
    #>
    [string]$ResourceId = $this.GetResourceId()
    [string]$ResourceIdPropertyName = $this.GetResourceIdPropertyName()

    hidden [string]GetResourceId()
    {
        return $this."$($this.GetResourceIdPropertyName())"
    }

    hidden [string]GetResourceIdPropertyName()
    {
        return "$($this.GetResourceName())Id"
    }



    <#
        .NOTES
            When creating an object via the Azure DevOps API, the 'Key' of the object will be
            another, alternate, unique key/identifier to the 'ResourceId' but this will be
            specific to the resource.

            This 'Key' can be used to determine an 'Id' of a new resource that has been added.
    #>
    [string]$ResourceKey = $this.GetResourceKey()
    [string]$ResourceKeyPropertyName = $this.GetResourceKeyPropertyName()

    hidden [string]GetResourceKey()
    {
        [string]$keyPropertyName = $this.GetResourceKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($keyPropertyName))
        {
            return $null
        }

        return $this."$keyPropertyName"
    }

    hidden [string]GetResourceKeyPropertyName() # TODO: Need to remove this from here (it's DSC specific)...
    {
        # Uses the same value as the 'DscResourceDscKeyPropertyName()'
        return $this.GetDscResourceKeyPropertyName()
    }



    hidden [Hashtable]GetResourceProperties()
    {
        [Hashtable]$thisProperties = @{}

        $this.GetDscPropertyNames() | ForEach-Object {
            $thisProperties."$_" = $this."$_"
        }

        return $thisProperties
    }



    hidden [string]GetResourceGetFunctionName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Get-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceNewFunctionName()
    {
        $thisResourceName = $this.GetResourceName()
        return "New-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceSetFunctionName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Set-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceRemoveFunctionName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Remove-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceTestFunctionName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Test-AzDevOps$thisResourceName"
    }

    hidden [string]GetResourceFunctionName([RequiredAction]$RequiredAction)
    {
        if ($RequiredAction -in @(
                [RequiredAction]::Get,
                [RequiredAction]::New,
                [RequiredAction]::Set,
                [RequiredAction]::Remove,
                [RequiredAction]::Test))
        {
            $thisResourceName = $this.GetResourceName()
            return "$($RequiredAction)-AzDevOps$thisResourceName"
        }

        return $null
    }

}



class DSC_AzDevOpsApiResource : AzDevOpsApiResource
{
    # DSC-specific properties for use in operations/comparisons
    [DscProperty()]
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat

    [DscProperty()]
    [Ensure]$Ensure


    # Constructor(s)
    DSC_AzDevOpsApiResource(){}



    <#
        .NOTES
            When creating an object via the Azure DevOps API, the 'Key' of the object will be
            another, alternate, unique key/identifier to the 'ResourceId' but this will be
            specific to the resource.

            This 'Key' can be used to determine an 'Id' of a new resource that has been added.
    #>
    [string]$DscResourceKey = $this.GetDscResourceKey()
    [string]$DscResourceKeyPropertyName = $this.GetDscResourceKeyPropertyName()

    hidden [string]GetDscResourceKey()
    {
        [string]$keyPropertyName = $this.GetDscResourceKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($keyPropertyName))
        {
            return $null
        }

        return $this."$keyPropertyName"
    }

    hidden [string]GetDscResourceKeyPropertyName()
    {
        [string[]]$thisDscKeyPropertyNames = @()

        [Type]$thisType = $this.GetType()
        [System.Reflection.PropertyInfo[]]$thisProperties = $thisType.GetProperties()

        $thisProperties | ForEach-Object {

            [System.Reflection.PropertyInfo]$propertyInfo = $_
            $PropertyName = $_.Name

            $propertyInfo.GetCustomAttributes($true) |
            ForEach-Object {

                if ($_.TypeId.Name -eq 'DscPropertyAttribute' -and
                    $_.Key -eq $true)
                {
                    $thisDscKeyPropertyNames += $PropertyName
                }
            }
        }

        if ($null -eq $thisDscKeyPropertyNames -or $thisDscKeyPropertyNames.Count -eq 0)
        {
            throw "Could not obtain a 'DscResourceDscKey' property for type '$($this.GetType().Name)'."
        }
        elseif ($thisDscKeyPropertyNames.Count -gt 1)
        {
            throw "Obtained more than 1 property for type '$($this.GetType().Name)' that was marked as a 'Key'. There must only be 1 property on the class set as the 'Key' for DSC."
        }

        return $thisDscKeyPropertyNames[0]
    }








    # DSC-specific methods
    hidden [System.String[]]GetDscPropertyNames()
    {
        [System.String[]]$thisDscPropertyNames = @()

        [Type]$thisType = $this.GetType()
        [System.Reflection.PropertyInfo[]]$thisProperties = $thisType.GetProperties()

        $thisProperties | ForEach-Object {
            $propertyInfo = $_
            $PropertyName = $_.Name

            $propertyInfo.GetCustomAttributes($true) |
            ForEach-Object {

                if ($_.TypeId.Name -eq 'DscPropertyAttribute')
                {
                    $thisDscPropertyNames += $PropertyName
                }
            }
        }

        return $thisDscPropertyNames
    }

    hidden [string[]]GetDscNoSetSupportPropertyNames()
    {
        return @()
    }






    hidden [object]GetCurrentStateResourceObject()
    {
        [string]$thisResourceKey = $this.GetResourceKey()
        [string]$thisResourceKeyPropertyName = $this.GetResourceKeyPropertyName()
        [string]$thisResourceId = $this.GetResourceId()
        [string]$thisResourceIdPropertyName = $this.GetResourceIdPropertyName()
        [string]$thisResourceGetFunctionName = $this.GetResourceGetFunctionName()

        $getParameters = @{
            ApiUri                         = $this.ApiUri
            Pat                            = $this.Pat
            "$thisResourceKeyPropertyName" = $thisResourceKey
        }

        if (![string]::IsNullOrWhiteSpace($thisResourceId))
        {
            Write-Verbose "thisResourceId was not null or whitespace."
            $getParameters."$thisResourceIdPropertyName" = $thisResourceId
        }

        $currentStateResourceObject = $(& $thisResourceGetFunctionName @getParameters)

        if ($null -eq $currentStateResourceObject)
        {
            return New-Object -TypeName 'PSObject' -Property @{
                Ensure = [Ensure]::Absent
            }
        }

        return $currentStateResourceObject
    }


    hidden [Hashtable]GetCurrentStateProperties()
    {
        # Obtain 'CurrentStateResourceObject' and pass into overidden function of inheriting class
        return $this.GetCurrentStateProperties($this.GetCurrentStateResourceObject())
    }

    # This method must be overidden by inheriting class(es)
    hidden [Hashtable]GetCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $thisType = $this.GetType()
        if ($thisType -eq [DSC_AzDevOpsApiResource])
        {
            throw "Method 'GetCurrentState()' in '$($thisType.Name)' must be overidden by an inheriting class."
            return $null
        }
        return $null
    }


    hidden [Hashtable]GetDesiredStateProperties()
    {
        return $this.GetResourceProperties()
    }


    hidden [RequiredAction]GetRequiredAction()
    {
        [hashtable]$currentProperties = $this.GetCurrentStateProperties()
        [hashtable]$desiredProperties = $this.GetDesiredStateProperties()

        [string[]]$propertyNamesWithNoSetSupport = $this.GetDscNoSetSupportPropertyNames()
        [string[]]$propertyNamesToCompare = $this.GetDscPropertyNames()


        # Update 'Id' property:
        # Set $desiredProperties."$IdPropertyName" to $currentProperties."$IdPropertyName" if it's desired
        # value is blank/null but it's current/existing value is known (and can be recovered from $currentProperties).
        #
        # This ensures that alternate keys (typically ResourceIds) not provided in the DSC configuration do not flag differences
        [string]$IdPropertyName = $this.GetResourceIdPropertyName()

        if ([string]::IsNullOrWhiteSpace($desiredProperties[$IdPropertyName]) -and
            ![string]::IsNullOrWhiteSpace($currentProperties[$IdPropertyName]))
        {
            $desiredProperties."$IdPropertyName" = $currentProperties."$IdPropertyName"
        }


        Write-Verbose '============================================================'
        Write-Verbose 'Current:'
        Write-Verbose $($currentProperties | ConvertTo-Json)
        Write-Verbose '============================================================'
        Write-Verbose 'Desired:'
        Write-Verbose $($desiredProperties | ConvertTo-Json)
        Write-Verbose '============================================================'


        # Perform logic with 'Ensure' (to determine whether resource should be created or dropped (or updated, if already [Ensure]::Present but property values differ)
        $requiredAction = [RequiredAction]::None

        switch ($desiredProperties.Ensure)
        {
            ([Ensure]::Present) {

                # If not already present, or different to expected/desired - return [RequiredAction]::New (i.e. Resource needs creating)
                if ($null -eq $currentProperties -or $($currentProperties.Ensure) -ne [Ensure]::Present)
                {
                    $requiredAction = [RequiredAction]::New
                }

                # Return if not [RequiredAction]::None
                if ($requiredAction -ne [RequiredAction]::None)
                {
                    return $requiredAction
                }

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a [RequiredAction]::New resource)
                if ($propertyNamesWithNoSetSupport.Count -gt 0)
                {
                    $propertyNamesWithNoSetSupport | ForEach-Object {

                        Write-Verbose "Comparing UNSUPPORTED: $_"
                        Write-Verbose $("Current: "+ $($currentProperties."$_"))
                        Write-Verbose $("Desired: "+ $($desiredProperties."$_"))

                        if ($($currentProperties[$_].ToString()) -ne $($desiredProperties[$_].ToString()))
                        {
                            throw "The '$($this.GetType().Name)', DSC resource does not support changes for/to the '$_' property."
                            $requiredAction = [RequiredAction]::Error
                        }
                    }
                }

                # Return if not [RequiredAction]::None
                if ($requiredAction -ne [RequiredAction]::None)
                {
                    return $requiredAction
                    break
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetRequiredAction RequiredAction  : Passed [RequiredAction]::Error"
                Write-Verbose "-----------------------------------------------------"

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a [RequiredAction]::New resource)
                if ($propertyNamesToCompare.Count -gt 0)
                {
                    $propertyNamesToCompare | ForEach-Object {

                        Write-Verbose "Comparing OK: $_"
                        Write-Verbose $("Current: "+ $($currentProperties."$_"))
                        Write-Verbose $("Desired: "+ $($desiredProperties."$_"))

                        if ($($currentProperties."$_") -ne $($desiredProperties."$_"))
                        {
                            $requiredAction = [RequiredAction]::Set
                        }
                    }
                }

                # Return if not [RequiredAction]::None
                if ($requiredAction -ne [RequiredAction]::None)
                {
                    return $requiredAction
                    break
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetRequiredAction RequiredAction  : Passed [RequiredAction]::Set"
                Write-Verbose "-----------------------------------------------------"

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $requiredAction
                break
            }
            ([Ensure]::Absent) {

                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $currentProperties -and $currentProperties.Ensure -ne [Ensure]::Absent)
                {
                    $requiredAction = [RequiredAction]::Remove
                }

                # Return if not [RequiredAction]::None
                if ($requiredAction -ne [RequiredAction]::None)
                {
                    return $requiredAction
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $requiredAction
                break
            }
            default {
                throw "Could not obtain a valid 'Ensure' value within 'DSC_AzDevOpsProject' Test() function. Value was '$($desiredProperties.Ensure)'."
                return [RequiredAction]::Error
            }
        }

        return $requiredAction
    }


    hidden [bool]IsInDesiredState()
    {
        if ($this.GetRequiredAction() -eq [RequiredAction]::None)
        {
            return $true
        }

        return $false
    }



    hidden [hashtable]GetDesiredStateParameters([hashtable]$CurrentStateProperties, [hashtable]$DesiredStateProperties, [RequiredAction]$RequiredAction)
    {
        [hashtable]$desiredStateParameters = $DesiredStateProperties
        [string]$IdPropertyName = $this.GetResourceIdPropertyName()


        # If actions required are 'None' or 'Error', return a $null value
        if ($RequiredAction -in @([RequiredAction]::None, [RequiredAction]::Error))
        {
            return $null
        }
        # If the desired state/action is to remove the resource, generate/return a minimal set of parameters required to remove the resource
        elseif ($RequiredAction -eq [RequiredAction]::Remove)
        {
            return @{
                ApiUri                      = $DesiredStateProperties.ApiUri
                Pat                         = $DesiredStateProperties.Pat

                # Set this from the 'Current' state as we would expect this to have an existing key/ID value to use
                "$IdPropertyName" = $CurrentStateProperties."$IdPropertyName"
            }
        }
        # If the desired state/action is to add/new or update/set  the resource, start with the values in the $DesiredStateProperties variable, and amend
        elseif ($RequiredAction -in @([RequiredAction]::New, [RequiredAction]::Set))
        {
            # Set $desiredParameters."$IdPropertyName" to $CurrentStateProperties."$IdPropertyName" if it's known and can be recovered from existing resource
            if ([string]::IsNullOrWhiteSpace($desiredStateParameters."$IdPropertyName") -and
                ![string]::IsNullOrWhiteSpace($CurrentStateProperties."$IdPropertyName"))
            {
                $desiredStateParameters."$IdPropertyName" = $CurrentStateProperties."$IdPropertyName"
            }
            # Alternatively, if $desiredParameters."$IdPropertyName" is null/empty, remove the key (as we don't want to pass an empty/null parameter)
            elseif ([string]::IsNullOrWhiteSpace($desiredStateParameters."$IdPropertyName"))
            {
                $desiredStateParameters.Remove($IdPropertyName)
            }


            # Do not need/want this passing as a parameter (the action taken will determine the desired state)
            $desiredStateParameters.Remove('Ensure')


            # Some DSC properties are only supported for 'New' and 'Remove' actions, but not 'Set' ones (these need to be removed)
            [string[]]$unsupportedForSetPropertyNames = $this.GetDscNoSetSupportPropertyNames()

            if ($RequiredAction -eq [RequiredAction]::Set -and
                $unsupportedForSetPropertyNames.Count -gt 0)
            {
                $unsupportedForSetPropertyNames | ForEach-Object {
                    $desiredStateParameters.Remove($_)
                }
            }

        }
        else
        {
            throw "A required action of '$RequiredAction' has not been catered for in GetDesiredStateParameters() method."
        }


        return $desiredStateParameters
    }


    [void] SetToDesiredState()
    {
        [RequiredAction]$requiredAction = $this.GetRequiredAction()

        if ($requiredAction -in @([RequiredAction]::'New', [RequiredAction]::'Set', [RequiredAction]::'Remove'))
        {
            $currentStateProperties = $this.GetCurrentStateProperties()
            $desiredStateProperties = $this.GetDesiredStateProperties()

            $requiredActionFunctionName = $this.GetResourceFunctionName($requiredAction)
            $desiredStateParameters = $this.GetDesiredStateParameters($currentStateProperties, $desiredStateProperties, $requiredAction)

            & $requiredActionFunctionName @desiredStateParameters -Force | Out-Null
            Start-Sleep -Seconds 5
        }
    }


}


[DscResource()]
class DSC_AzDevOpsProject : DSC_AzDevOpsApiResource
{
    [DscProperty()]
    [Alias('Id')]
    [string]$ProjectId

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [string]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [string]$ProjectDescription

    [DscProperty()]
    [string]$SourceControlType


    [DSC_AzDevOpsProject] Get()
    {
        return [DSC_AzDevOpsProject]$($this.GetCurrentStateProperties())
    }

    [bool] Test()
    {
        return $this.IsInDesiredState()
    }

    [void] Set()
    {
        $this.SetToDesiredState()
    }


    hidden [string[]]GetDscNoSetSupportPropertyNames()
    {
        return @('SourceControlType')
    }

    hidden [Hashtable]GetCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Pat = $this.Pat
            ApiUri = $this.ApiUri
            Ensure = [Ensure]::Absent
        }

        if ($null -ne $CurrentResourceObject)
        {
            if (![string]::IsNullOrWhiteSpace($CurrentResourceObject.id))
            {
                $properties.Ensure = [Ensure]::Present
            }
            $properties.ProjectId = $CurrentResourceObject.id
            $properties.ProjectName = $CurrentResourceObject.name
            $properties.ProjectDescription = $CurrentResourceObject.description
            $properties.SourceControlType = $CurrentResourceObject.capabilities.versioncontrol.sourceControlType
        }

        return $properties
    }

}
