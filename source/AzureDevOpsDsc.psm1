$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Common'
$script:azureDevOpsDscServerModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Server'
$script:azureDevOpsDscServicesModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\AzureDevOpsDsc.Services'
#$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DscResource.Common'

Import-Module -Name $script:azureDevOpsDscCommonModulePath
Import-Module -Name $script:azureDevOpsDscServerModulePath
Import-Module -Name $script:azureDevOpsDscServicesModulePath
#Import-Module -Name $script:dscResourceCommonModulePath
#
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
    [DscProperty()]
    [Alias('Uri')]
    [string]$ApiUri

    [DscProperty()]
    [Alias('PersonalAccessToken')]
    [string]$Pat

    [DscProperty()]
    [Ensure]$Ensure


    # Non-DSC properties for use in operations/comparisons


    # Hidden properties
    hidden [string]$ResourceKey
    hidden [string]$ResourceKeyPropertyName
    hidden [string]$ResourceName = $this.GetResourceName()
    #hidden [hashtable]$ResourceProperties = $this.GetResourceProperties()


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
        # Uses the same value as the 'DscResourceDscKeyPropertyName'
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


    # This method must be overidden by inheriting classes
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
        #[PSObject]$thisObject = $this
        [Hashtable]$thisProperties = @{}

        $this.GetDscResourceDscPropertyNames() | ForEach-Object {
            $thisProperties."$_" = $this."$_"
        }
        #$thisObject.PSObject.Properties | ForEach-Object {
        #    $thisProperties[$_.Name] = $_.Value
        #}

        return $thisProperties
    }


    hidden [string]GetResourceGetMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Get-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceSetMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Set-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceRemoveMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Remove-AzDevOps$thisResourceName"
    }
    hidden [string]GetResourceTestMethodName()
    {
        $thisResourceName = $this.GetResourceName()
        return "Test-AzDevOps$thisResourceName"
    }


    hidden [object]GetCurrentStateResourceObject()
    {
        Write-Verbose "GetCurrentStateResourceObject()..."
        [string]$thisResourceKey = $this.GetResourceKey()
        [string]$thisResourceKeyPropertyName = $this.GetResourceKeyPropertyName()
        [string]$thisResourceAlternateKey = $this.GetResourceAlternateKey()
        [string]$thisResourceAlternateKeyPropertyName = $this.GetResourceAlternateKeyPropertyName()
        [string]$thisResourceGetMethodName = $this.GetResourceGetMethodName()

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

        #Write-Verbose "Calling '$thisResourceGetMethodName'..."
        #Write-Verbose $($getParameters | ConvertTo-Json)
        $currentStateResourceObject = $(& $thisResourceGetMethodName @getParameters)
        #Write-Verbose "'$thisResourceGetMethodName' end..."
        #Write-Verbose $($currentStateResourceObject | ConvertTo-Json)

        if ($null -eq $currentStateResourceObject)
        {
            #Write-Verbose "currentStateResourceObject was null."
            return New-Object -TypeName 'PSObject' -Property @{
                Ensure = [Ensure]::Absent
            }
        }

        #Write-Verbose "GetCurrentStateResourceObject() end."
        return $currentStateResourceObject
    }


    hidden [Hashtable]GetCurrentStateProperties()
    {
        # Obtain 'CurrentStateResourceObject' and pass into overidden function of inheriting class
        return $this.GetCurrentStateProperties($this.GetCurrentStateResourceObject())
    }

    # This method must be overidden by inheriting classes
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


    hidden [string]GetRequiredAction()
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
        Write-Verbose "got ... alternateKeyPropertyName : $alternateKeyPropertyName"
        if ([string]::IsNullOrWhiteSpace($desiredProperties[$alternateKeyPropertyName]) -and
            ![string]::IsNullOrWhiteSpace($currentProperties[$alternateKeyPropertyName]))
        {
            Write-Verbose "Set ... alternateKeyPropertyName"
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
        $requiredAction = 'None'

        switch ($desiredProperties.Ensure)
        {
            ([Ensure]::Present) {

                # If not already present, or different to expected/desired - return 'New' (i.e. Resource needs creating)
                if ($null -eq $currentProperties -or $($currentProperties.Ensure.ToString()) -ne [Ensure]::Present)
                {
                    $requiredAction = 'New'
                }

                # Return if not 'None'
                if ($requiredAction -ne 'None')
                {
                    return $requiredAction
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetRequiredAction RequiredAction  : Passed 'New'"
                Write-Verbose "-----------------------------------------------------"

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a 'New' resource)
                if ($propertyNamesUnsupportedForSet.Count -gt 0)
                {
                    $propertyNamesUnsupportedForSet | ForEach-Object {

                        Write-Verbose "Comparing UNSUPPORTED: $_"
                        Write-Verbose $("Current: "+ $($currentProperties."$_"))
                        Write-Verbose $("Desired: "+ $($desiredProperties."$_"))

                        if ($($currentProperties[$_].ToString()) -ne $($desiredProperties[$_].ToString()))
                        {
                            throw "The '$($this.GetType().Name)', DSC resource does not support changes for/to the '$_' property."
                            $requiredAction = 'Error'
                        }
                    }
                }

                # Return if not 'None'
                if ($requiredAction -ne 'None')
                {
                    return $requiredAction
                    break
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetRequiredAction RequiredAction  : Passed 'Error'"
                Write-Verbose "-----------------------------------------------------"

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a 'New' resource)
                if ($propertyNamesToCompare.Count -gt 0)
                {
                    $propertyNamesToCompare | ForEach-Object {

                        Write-Verbose "Comparing OK: $_"
                        Write-Verbose $("Current: "+ $($currentProperties."$_"))
                        Write-Verbose $("Desired: "+ $($desiredProperties."$_"))

                        if ($($currentProperties."$_") -ne $($desiredProperties."$_"))
                        {
                            $requiredAction = 'Set'
                        }
                    }
                }

                # Return if not 'None'
                if ($requiredAction -ne 'None')
                {
                    return $requiredAction
                    break
                }

                Write-Verbose "-----------------------------------------------------"
                Write-Verbose "GetRequiredAction RequiredAction  : Passed 'Set'"
                Write-Verbose "-----------------------------------------------------"

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $requiredAction
                break
            }
            ([Ensure]::Absent) {

                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $currentProperties -and $currentProperties.Ensure -ne [Ensure]::Absent)
                {
                    $requiredAction = 'Remove'
                }

                # Return if not 'None'
                if ($requiredAction -ne 'None')
                {
                    return $requiredAction
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $requiredAction
                break
            }
            default {
                throw "Could not obtain a valid 'Ensure' value within 'DSC_AzDevOpsProject' Test() function. Value was '$($desiredProperties.Ensure)'."
                return 'Error'
            }
        }

        return $requiredAction
    }


    hidden [bool]IsInDesiredState()
    {
        if ($this.GetRequiredAction() -eq 'None')
        {
            return $true
        }

        return $false
    }


    [bool] TestNew()
    {
        return $this.IsInDesiredState()
    }

}


[DscResource()]
class DSC_AzDevOpsProject : DSC_AzDevOpsResource
{

    [Hashtable]GetCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        Write-Verbose "GetCurrentStateProperties()..."
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
            #Write-Verbose "(CurrentResourceObject was not null)..."
            #Write-Verbose $($CurrentResourceObject | ConvertTo-Json)
            $properties.ProjectId = $CurrentResourceObject.id
            $properties.ProjectName = $CurrentResourceObject.name
            $properties.ProjectDescription = $CurrentResourceObject.description
            $properties.SourceControlType = $CurrentResourceObject.capabilities.versioncontrol.sourceControlType
        }
        #Write-Verbose 'properties'
        #Write-Verbose $($properties | ConvertTo-Json)
        #Write-Verbose "GetCurrentStateProperties() end."
        return $properties
    }



    [DscProperty()] # Note: Do want to be able to pass this back populated so not set as 'NotConfigurable'
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


    [PSCustomObject]GetAzDevOpsResource()
    {
        $getParameters = @{
            ApiUri             = $this.ApiUri
            Pat                = $this.Pat

            ProjectName        = $this.ProjectName
        }

        if (![string]::IsNullOrWhiteSpace($this.ProjectId))
        {
            $getParameters.ProjectId = $this.ProjectId
        }

        Write-Verbose "GetAzDevOpsResource()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "

        return Get-AzDevOpsProject @getParameters
    }


    [DSC_AzDevOpsProject] Get()
    {
        $existing = $this.GetAzDevOpsResource()

        if ($null -eq $existing)
        {
            return [DSC_AzDevOpsProject]@{

                # Existing properties
                ApiUri = $this.ApiUri
                Pat = $this.Pat
                ProjectName = $this.ProjectName

                # Updated properties (from 'Get')
                Ensure = [Ensure]::Absent
            }
        }

        Write-Verbose "Get()..."
        Write-Verbose "this.Ensure                 : $($this.Ensure) "
        Write-Verbose "this.ProjectId              : $($this.ProjectId) "
        Write-Verbose "this.ProjectName            : $($this.ProjectName) "
        Write-Verbose "this.ProjectDescription     : $($this.ProjectDescription) "
        Write-Verbose "this.SourceControlType      : $($this.SourceControlType) "
        Write-Verbose "existing.Ensure             : $($existing.Ensure) "
        Write-Verbose "existing.ProjectId          : $($existing.ProjectId) "
        Write-Verbose "existing.ProjectName        : $($existing.ProjectName) "
        Write-Verbose "existing.ProjectDescription : $($existing.ProjectDescription) "
        Write-Verbose "existing.SourceControlType  : $($existing.SourceControlType) "

        return [DSC_AzDevOpsProject]@{

            # Existing properties
            ApiUri = $this.ApiUri
            Pat = $this.Pat


            # Updated properties (from 'Get')
            Ensure = [Ensure]::Present
            ProjectId = $existing.id
            ProjectName = $existing.name
            ProjectDescription = $existing.description
            SourceControlType = $existing.capabilities.versioncontrol.sourceControlType
        }

    }



    [bool] Test()
    {
        return $this.IsInDesiredState()
    }


    [void] Set()
    {
        Write-Verbose "Set()..."


        $requiredFunction = $this.GetRequiredAction()
        Write-Verbose "-----------------------------------------------------"
        Write-Verbose "RequiredFunction  : $requiredFunction"
        Write-Verbose "-----------------------------------------------------"


        $current = $this.GetCurrentStateProperties()
        $desired = $this.GetDesiredStateProperties()

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


        # Set $this.ProjectId to $existing.ProjectId if it's known and can be recovered from existing resource
        if ([string]::IsNullOrWhiteSpace($desired.ProjectId) -and ![string]::IsNullOrWhiteSpace($current.ProjectId))
        {
            $desired.ProjectId = $current.ProjectId
            Write-Verbose "desired.ProjectId              : $($desired.ProjectId) (Since updated)"
        }


        $newSetParameters = @{
            ApiUri             = $current.ApiUri
            Pat                = $current.Pat

            ProjectName        = $desired.ProjectName
            ProjectDescription = $desired.ProjectDescription

            SourceControlType  = $desired.SourceControlType
        }

        if (![string]::IsNullOrWhiteSpace($desired.ProjectId))
        {
            $newSetParameters.ProjectId = $desired.ProjectId
        }


        switch ($requiredFunction)
        {
            'None' {
                break
            }
            'New' {
                New-AzDevOpsProject @newSetParameters -Force | Out-Null
                Start-Sleep -Seconds 5
                break
            }
            'Set' {
                # Remove any not supported
                $newSetParameters.Remove('SourceControlType')


                Set-AzDevOpsProject @newSetParameters -Force | Out-Null
                Start-Sleep -Seconds 5
                break
            }
            'Remove' {
                $removeParameters = @{
                    ApiUri             = $newSetParameters.ApiUri
                    Pat                = $newSetParameters.Pat

                    ProjectId          = $newSetParameters.ProjectId
                }

                Remove-AzDevOpsProject @removeParameters -Force | Out-Null
                Start-Sleep -Seconds 5
                break
            }
            default {
                throw "Could not obtain a valid 'RequiredAction' value within 'DSC_AzDevOpsProject' Set() function."
            }
        }

    }

}
