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



class DSC_AzDevOpsResource
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


    # Hidden, non-DSC properties for use in operations/comparisons
    hidden [string]$ResourceKey
    hidden [string]$ResourceKeyPropertyName
    hidden [string]$ResourceName = $this.GetResourceName()


    # Constructor(s)
    DSC_AzDevOpsResource(){}


    # DSC-specific methods
    hidden [string[]]GetDscResourceDscPropertyNames()
    {
        [string[]]$thisDscPropertyNames = @()

        [Type]$thisType = $this.GetType()
        [System.Reflection.PropertyInfo[]]$thisProperties = $thisType.GetProperties()

        $thisProperties | ForEach-Object {
            [System.Reflection.PropertyInfo]$propertyInfo = $_
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

    hidden [string]GetDscResourceDscKeyPropertyName()
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




    # Non DSC-specific methods

    hidden [string]GetResourceName()
    {
        # Assumes a naming convention is followed between the DSC
        # resource name and the name of the resource within the API
        return $this.GetType().ToString().Replace('DSC_AzDevOps','')
    }


    hidden [string]GetResourceKeyPropertyName()
    {
        # Uses the same value as the 'DscResourceDscKeyPropertyName()'
        return $this.GetDscResourceDscKeyPropertyName()
    }


    hidden [string]GetResourceKey()
    {
        [string]$keyPropertyName = $this.GetResourceKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($keyPropertyName))
        {
            return $null
        }

        return $this."$keyPropertyName"
    }


    hidden [string]GetResourceAlternateKeyPropertyName()
    {
        return "$($this.GetResourceName())Id"
    }


    hidden [string]GetResourceAlternateKey()
    {
        return $this."$($this.GetResourceAlternateKeyPropertyName())"
    }


    hidden [Hashtable]GetResourceProperties()
    {
        [Hashtable]$thisProperties = @{}

        $this.GetDscResourceDscPropertyNames() | ForEach-Object {
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


    hidden [object]GetCurrentStateResourceObject()
    {
        [string]$thisResourceKey = $this.GetResourceKey()
        [string]$thisResourceKeyPropertyName = $this.GetResourceKeyPropertyName()
        [string]$thisResourceAlternateKey = $this.GetResourceAlternateKey()
        [string]$thisResourceAlternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()
        [string]$thisResourceGetFunctionName = $this.GetResourceGetFunctionName()

        $getParameters = @{
            ApiUri                         = $this.ApiUri
            Pat                            = $this.Pat
            "$thisResourceKeyPropertyName" = $thisResourceKey
        }

        if (![string]::IsNullOrWhiteSpace($thisResourceAlternateKey))
        {
            Write-Verbose "thisResourceAlternateKey was not null or whitespace."
            $getParameters."$thisResourceAlternateKeyPropertyName" = $thisResourceAlternateKey
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
        if ($thisType -eq [DSC_AzDevOpsResource])
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

        [string[]]$propertyNamesUnsupportedForSet = @()
        [string[]]$propertyNamesToCompare = $this.GetDscResourceDscPropertyNames()


        # Update 'AlternateKey' property:
        # Set $desiredProperties."$alternateKeyPropertyName" to $currentProperties."$alternateKeyPropertyName" if it's desired
        # value is blank/null but it's current/existing value is known (and can be recovered from $currentProperties).
        #
        # This ensures that alternate keys (typically ResourceIds) not provided in the DSC configuration do not flag differences
        [string]$alternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()

        if ([string]::IsNullOrWhiteSpace($desiredProperties[$alternateKeyPropertyName]) -and
            ![string]::IsNullOrWhiteSpace($currentProperties[$alternateKeyPropertyName]))
        {
            $desiredProperties."$alternateKeyPropertyName" = $currentProperties."$alternateKeyPropertyName"
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
                if ($propertyNamesUnsupportedForSet.Count -gt 0)
                {
                    $propertyNamesUnsupportedForSet | ForEach-Object {

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

}


[DscResource()]
class DSC_AzDevOpsProject : DSC_AzDevOpsResource
{
    [DSC_AzDevOpsProject] Get()
    {
        return [DSC_AzDevOpsProject]$($this.GetCurrentStateProperties())
    }

    [bool] Test()
    {
        return $this.IsInDesiredState()
    }

    [Hashtable]GetCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
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



    [void] Set()
    {
        Write-Verbose "Set()..."

        [RequiredAction]$requiredAction = $this.GetRequiredAction()

        $current = $this.GetCurrentStateProperties()
        $desired = $this.GetDesiredStateProperties()
        $desiredParameters = $desired

        $alternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()

        Write-Verbose "current.Ensure                 : $($current.Ensure) "
        Write-Verbose "current.ProjectId              : $($current.ProjectId) "
        Write-Verbose "current.ProjectName            : $($current.ProjectName) "
        Write-Verbose "current.ProjectDescription     : $($current.ProjectDescription) "
        Write-Verbose "current.SourceControlType      : $($current.SourceControlType) "
        Write-Verbose "desired.Ensure                 : $($desired.Ensure) "
        Write-Verbose "desired.ProjectId              : $($desired.ProjectId) "
        Write-Verbose "desired.ProjectName            : $($desired.ProjectName) "
        Write-Verbose "desired.ProjectDescription     : $($desired.ProjectDescription) "
        Write-Verbose "desired.SourceControlType      : $($desired.SourceControlType) "


        # Set $desiredParameters."$alternateKeyPropertyName" to $current."$alternateKeyPropertyName" if it's known and can be recovered from existing resource
        if ([string]::IsNullOrWhiteSpace($desiredParameters."$alternateKeyPropertyName") -and
            ![string]::IsNullOrWhiteSpace($current."$alternateKeyPropertyName"))
        {
            $desiredParameters."$alternateKeyPropertyName" = $current."$alternateKeyPropertyName"
            Write-Verbose $("desired.$alternateKeyPropertyName  : "+$($desired."$alternateKeyPropertyName")+" (Since updated)")
        }
        # Alternatively, if $desiredParameters."$alternateKeyPropertyName" is null/empty, remove it (as we don't want to pass an empty/null parameter)
        elseif ([string]::IsNullOrWhiteSpace($desiredParameters."$alternateKeyPropertyName"))
        {
            $desiredParameters.Remove($alternateKeyPropertyName)
        }


        $desiredParameters.Remove('Ensure')


        switch ($requiredAction)
        {
            ([RequiredAction]::'None') {
                break
            }
            ([RequiredAction]::'New') {
                $thisResourceNewFunctionName = $this.GetResourceNewFunctionName()

                Write-Verbose "Calling '$thisResourceNewFunctionName'..."
                Write-Verbose $($desiredParameters | ConvertTo-Json)
                & $thisResourceNewFunctionName @desiredParameters -Force | Out-Null
                Start-Sleep -Seconds 5
                break
            }
            ([RequiredAction]::'Set') {
                # Remove any not supported
                $desiredParameters.Remove('SourceControlType')


                $thisResourceSetFunctionName = $this.GetResourceSetFunctionName()
                Write-Verbose "Calling '$thisResourceSetFunctionName'..."
                Write-Verbose $($desiredParameters | ConvertTo-Json)
                & $thisResourceSetFunctionName @desiredParameters -Force | Out-Null
                Start-Sleep -Seconds 5
                break
            }
            ([RequiredAction]::'Remove') {
                $removeParameters = @{
                    ApiUri                      = $desiredParameters.ApiUri
                    Pat                         = $desiredParameters.Pat

                    "$alternateKeyPropertyName" = $desiredParameters."$alternateKeyPropertyName"
                }

                $thisResourceRemoveFunctionName = $this.GetResourceRemoveFunctionName()
                Write-Verbose "Calling '$thisResourceRemoveFunctionName'..."
                & $thisResourceRemoveFunctionName @removeParameters -Force | Out-Null
                Start-Sleep -Seconds 5
                break
            }
            default {
                throw "Could not obtain a valid 'RequiredAction' value within 'DSC_AzDevOpsProject' Set() function."
            }
        }

    }

}
