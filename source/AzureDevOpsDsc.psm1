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
    Get
    New
    Set
    Remove
    Test
    Error
}



class AzDevOpsDscResource
{
    hidden [System.String]GetDscResourceKey()
    {
        [System.String]$dscResourceKeyPropertyName = $this.GetDscResourceKeyPropertyName()

        if ([System.String]::IsNullOrWhiteSpace($dscResourceKeyPropertyName))
        {
            return $null
        }

        return $this."$dscResourceKeyPropertyName"
    }

    hidden [System.String]GetDscResourceKeyPropertyName()
    {
        [System.String[]]$dscResourceKeyPropertyNames = @()

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
                    $dscResourceKeyPropertyNames += $PropertyName
                }
            }
        }

        if ($null -eq $dscResourceKeyPropertyNames -or $dscResourceKeyPropertyNames.Count -eq 0)
        {
            throw "Could not obtain a 'DscResourceDscKey' property for type '$($this.GetType().Name)'."
        }
        elseif ($dscResourceKeyPropertyNames.Count -gt 1)
        {
            throw "Obtained more than 1 property for type '$($this.GetType().Name)' that was marked as a 'Key'. There must only be 1 property on the class set as the 'Key' for DSC."
        }

        return $dscResourceKeyPropertyNames[0]
    }


    hidden [System.String[]]GetDscResourcePropertyNames()
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

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
    }

}

class AzDevOpsApiDscResource : AzDevOpsDscResource
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



class DSC_AzDevOpsApiResource : AzDevOpsApiDscResource
{
    [DscProperty()]
    [Alias('Uri')]
    [System.String]
    $ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [System.String]
    $Pat

    [DscProperty()]
    [Ensure]
    $Ensure



    hidden [System.Management.Automation.PSObject]GetDscResourceCurrentStateObject()
    {
        # Setup a default set of parameters to pass into the object's 'Get' method
        $getParameters = @{
            ApiUri                                  = $this.ApiUri
            Pat                                     = $this.Pat
            "$($this.GetResourceKeyPropertyName())" = $this.GetResourceKey()
        }

        # If there is an available 'ResourceId' value, add it to the parameters/hashtable
        if (![System.String]::IsNullOrWhiteSpace($this.GetResourceId()))
        {
            $getParameters."$($this.GetResourceIdPropertyName())" = $this.GetResourceId()
        }

        # Obtain the 'Get' function name for the object, then invoke it
        $thisResourceGetFunctionName = $this.GetResourceFunctionName(([RequiredAction]::Get))
        $currentStateResourceObject = $(& $thisResourceGetFunctionName @getParameters)

        # If no object was returned (i.e it does not exist), create a default/empty object
        if ($null -eq $currentStateResourceObject)
        {
            return New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                Ensure = [Ensure]::Absent
            }
        }

        return $currentStateResourceObject
    }


    hidden [Hashtable]GetDscCurrentStateProperties()
    {
        # Obtain 'CurrentStateResourceObject' and pass into overidden function of inheriting class
        return $this.GetDscCurrentStateProperties($this.GetDscResourceCurrentStateObject())
    }

    # This method must be overidden by inheriting class(es)
    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        # Obtain the type of $this object. Throw an exception if this is being called from the base class method.
        $thisType = $this.GetType()
        if ($thisType -eq [DSC_AzDevOpsApiResource])
        {
            throw "Method 'GetCurrentState()' in '$($thisType.Name)' must be overidden and called by an inheriting class."
        }
        return $null
    }


    hidden [Hashtable]GetDscDesiredStateProperties()
    {
        [Hashtable]$desiredStateProperties = @{}

        # Obtain all DSC-related properties, and add to the hashtable output
        $this.GetDscResourcePropertyNames() | ForEach-Object {
                $desiredStateProperties."$_" = $this."$_"
            }

        return $desiredStateProperties
    }


    hidden [RequiredAction]GetDscRequiredAction()
    {
        [Hashtable]$currentProperties = $this.GetDscCurrentStateProperties()
        [Hashtable]$desiredProperties = $this.GetDscDesiredStateProperties()

        [System.String[]]$propertyNamesWithNoSetSupport = $this.GetDscResourcePropertyNamesWithNoSetSupport()
        [System.String[]]$propertyNamesToCompare = $this.GetDscResourcePropertyNames()


        # Update 'Id' property:
        # Set $desiredProperties."$IdPropertyName" to $currentProperties."$IdPropertyName" if it's desired
        # value is blank/null but it's current/existing value is known (and can be recovered from $currentProperties).
        #
        # This ensures that alternate keys (typically ResourceIds) not provided in the DSC configuration do not flag differences
        [System.String]$IdPropertyName = $this.GetResourceIdPropertyName()

        if ([System.String]::IsNullOrWhiteSpace($desiredProperties[$IdPropertyName]) -and
            ![System.String]::IsNullOrWhiteSpace($currentProperties[$IdPropertyName]))
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
        $dscRequiredAction = [RequiredAction]::None

        switch ($desiredProperties.Ensure)
        {
            ([Ensure]::Present) {

                # If not already present, or different to expected/desired - return [RequiredAction]::New (i.e. Resource needs creating)
                if ($null -eq $currentProperties -or $($currentProperties.Ensure) -ne [Ensure]::Present)
                {
                    $dscRequiredAction = [RequiredAction]::New
                }

                # Return if not [RequiredAction]::None
                if ($dscRequiredAction -ne [RequiredAction]::None)
                {
                    return $dscRequiredAction
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
                            $dscRequiredAction = [RequiredAction]::Error
                        }
                    }
                }

                # Return if not [RequiredAction]::None
                if ($dscRequiredAction -ne [RequiredAction]::None)
                {
                    return $dscRequiredAction
                    break
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetDscRequiredAction RequiredAction  : Passed [RequiredAction]::Error"
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
                            $dscRequiredAction = [RequiredAction]::Set
                        }
                    }
                }

                # Return if not [RequiredAction]::None
                if ($dscRequiredAction -ne [RequiredAction]::None)
                {
                    return $dscRequiredAction
                    break
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetDscRequiredAction RequiredAction  : Passed [RequiredAction]::Set"
                Write-Verbose "-----------------------------------------------------"

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $dscRequiredAction
                break
            }
            ([Ensure]::Absent) {

                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $currentProperties -and $currentProperties.Ensure -ne [Ensure]::Absent)
                {
                    $dscRequiredAction = [RequiredAction]::Remove
                }

                # Return if not [RequiredAction]::None
                if ($dscRequiredAction -ne [RequiredAction]::None)
                {
                    return $dscRequiredAction
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $dscRequiredAction
                break
            }
            default {
                throw "Could not obtain a valid 'Ensure' value within 'DSC_AzDevOpsProject' Test() function. Value was '$($desiredProperties.Ensure)'."
                return [RequiredAction]::Error
            }
        }

        return $dscRequiredAction
    }


    hidden [System.Boolean]IsInDesiredState()
    {
        if ($this.GetDscRequiredAction() -eq [RequiredAction]::None)
        {
            return $true
        }

        return $false
    }



    hidden [Hashtable]GetDesiredStateParameters([Hashtable]$CurrentStateProperties, [Hashtable]$DesiredStateProperties, [RequiredAction]$RequiredAction)
    {
        [Hashtable]$desiredStateParameters = $DesiredStateProperties
        [System.String]$IdPropertyName = $this.GetResourceIdPropertyName()


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
            if ([System.String]::IsNullOrWhiteSpace($desiredStateParameters."$IdPropertyName") -and
                ![System.String]::IsNullOrWhiteSpace($CurrentStateProperties."$IdPropertyName"))
            {
                $desiredStateParameters."$IdPropertyName" = $CurrentStateProperties."$IdPropertyName"
            }
            # Alternatively, if $desiredParameters."$IdPropertyName" is null/empty, remove the key (as we don't want to pass an empty/null parameter)
            elseif ([System.String]::IsNullOrWhiteSpace($desiredStateParameters."$IdPropertyName"))
            {
                $desiredStateParameters.Remove($IdPropertyName)
            }


            # Do not need/want this passing as a parameter (the action taken will determine the desired state)
            $desiredStateParameters.Remove('Ensure')


            # Some DSC properties are only supported for 'New' and 'Remove' actions, but not 'Set' ones (these need to be removed)
            [System.String[]]$unsupportedForSetPropertyNames = $this.GetDscResourcePropertyNamesWithNoSetSupport()

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
        [RequiredAction]$dscRequiredAction = $this.GetDscRequiredAction()

        if ($dscRequiredAction -in @([RequiredAction]::'New', [RequiredAction]::'Set', [RequiredAction]::'Remove'))
        {
            $dscCurrentStateProperties = $this.GetDscCurrentStateProperties()
            $dscDesiredStateProperties = $this.GetDscDesiredStateProperties()

            $dscRequiredActionFunctionName = $this.GetResourceFunctionName($dscRequiredAction)
            $dscDesiredStateParameters = $this.GetDesiredStateParameters($dscCurrentStateProperties, $dscDesiredStateProperties, $dscRequiredAction)

            & $dscRequiredActionFunctionName @dscDesiredStateParameters -Force | Out-Null
            Start-Sleep -Seconds 5
        }
    }


}


[DscResource()]
class DSC_AzDevOpsProject : DSC_AzDevOpsApiResource
{
    [DscProperty()]
    [Alias('Id')]
    [System.String]$ProjectId

    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$ProjectDescription

    [DscProperty()]
    [System.String]$SourceControlType


    [DSC_AzDevOpsProject] Get()
    {
        return [DSC_AzDevOpsProject]$($this.GetDscCurrentStateProperties())
    }

    [System.Boolean] Test()
    {
        return $this.IsInDesiredState()
    }

    [void] Set()
    {
        $this.SetToDesiredState()
    }


    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @('SourceControlType')
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Pat = $this.Pat
            ApiUri = $this.ApiUri
            Ensure = [Ensure]::Absent
        }

        if ($null -ne $CurrentResourceObject)
        {
            if (![System.String]::IsNullOrWhiteSpace($CurrentResourceObject.id))
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
