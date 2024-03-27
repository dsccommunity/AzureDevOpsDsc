<#
    .SYNOPSIS
        Defines a base class from which other AzureDevOps DSC resources inherit from.
#>
class AzDevOpsDscResourceBase : AzDevOpsApiDscResourceBase
{
    [DscProperty()]
    [Ensure]
    $Ensure

    [DscProperty(NotConfigurable)]
    [Alias('result')]
    [HashTable]$LookupResult

    hidden [Hashtable]GetDscCurrentStateObjectGetParameters()
    {
        # Setup a default set of parameters to pass into the resource/object's 'Get' method
        $getParameters = @{
            "$($this.GetResourceKeyPropertyName())" = $this.GetResourceKey()
        }

        # If there is an available 'ResourceId' value, add it to the parameters/hashtable
        if (![System.String]::IsNullOrWhiteSpace($this.GetResourceId()))
        {
            $getParameters."$($this.GetResourceIdPropertyName())" = $this.GetResourceId()
        }

        return $getParameters
    }


    hidden [PsObject]GetDscCurrentStateResourceObject([Hashtable]$GetParameters)
    {
        # Obtain the 'Get' function name for the object, then invoke it
        $thisResourceGetFunctionName = $this.GetResourceFunctionName(([RequiredAction]::Get))
        return $(& $thisResourceGetFunctionName @GetParameters)
    }


    hidden [HashTable]GetDscCurrentStateObject()
    {
        # Declare the result hashtable
        $props = @{
            GroupName = $this.GroupName
            GroupDisplayName = $this.GroupDisplayName
            GroupDescription = $this.GroupDescription
        }

        $getParameters      = $this.GetDscCurrentStateObjectGetParameters()
        $props.LookupResult = $this.GetDscCurrentStateResourceObject($getParameters)
        $props.Ensure       = $props.LookupResult.Ensure

        return $props

    }


    hidden [Hashtable]GetDscCurrentStateProperties()
    {
        # Obtain 'CurrentStateResourceObject' and pass into overidden function of inheriting class
        return $this.GetDscCurrentStateProperties($this.GetDscCurrentStateObject())
    }

    # This method must be overidden by inheriting class(es)
    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        # Obtain the type of $this object. Throw an exception if this is being called from the base class method.
        $thisType = $this.GetType()
        if ($thisType -eq [AzDevOpsDscResourceBase])
        {
            $errorMessage = "Method 'GetCurrentState()' in '$($thisType.Name)' must be overidden and called by an inheriting class."
            New-InvalidOperationException -Message $errorMessage
        }
        return $null
    }

    hidden [Object[]]FindEnumValuesForInteger([System.Type]$EnumType, [Int32]$Value)
    {
        [System.Collections.ArrayList]$enumValues = @()

        [System.Array]$enumValues = [System.Enum]::GetValues($EnumType)

        [System.Collections.ArrayList]$matchingEnumValues = @()

        $enumValues | ForEach-Object {
            if ($Value -band $_ -eq $_)
            {
                $matchingEnumValues.Add($_)
            }
        }

        return $matchingEnumValues.ToArray()
    }

    hidden [Hashtable]GetDscDesiredStateProperties()
    {
        [Hashtable]$dscDesiredStateProperties = @{}

        # Obtain all DSC-related properties, and add them and their values to the hashtable output
        $this.GetDscResourcePropertyNames() | ForEach-Object {
                $dscDesiredStateProperties."$_" = $this."$_"
            }

        return $dscDesiredStateProperties
    }


    hidden [RequiredAction]GetDscRequiredAction()
    {
        # Perform logic with 'Ensure' (to determine whether resource should be created or dropped (or updated, if already [Ensure]::Present but property values differ)
        $dscRequiredAction = [RequiredAction]::None
        #$cacheProperties = $false

        [Hashtable]$currentProperties = $this.GetDscCurrentStateProperties()
        [Hashtable]$desiredProperties = $this.GetDscDesiredStateProperties()

        [System.String[]]$dscPropertyNamesWithNoSetSupport = $this.GetDscResourcePropertyNamesWithNoSetSupport()
        [System.String[]]$dscPropertyNamesToCompare = $this.GetDscResourcePropertyNames()

        switch ($desiredProperties.Ensure)
        {
            ([Ensure]::Present) {

                # If the desired state is to add the resource, however the current resource is absent. It is not in state.
                if ($currentProperties.Ensure -eq [Ensure]::Absent)
                {
                    # The resource is not in the desired state and is not present.
                    if ($currentProperties.LookupResult.Status -eq [DSCGetSummaryState]::NotFound)
                    {
                        $dscRequiredAction = [RequiredAction]::New
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }
                    # If the resource has been renamed or changed, it is not in state. The resource needs to be updated.
                    if ($currentProperties.LookupResult.Status -in ([DSCGetSummaryState]::Changed, [DSCGetSummaryState]::Renamed))
                    {
                        $dscRequiredAction = [RequiredAction]::Set
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }

                    return $dscRequiredAction
                    break

                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $dscRequiredAction
                break

            }
            ([Ensure]::Absent) {

                if ($currentProperties.LookupResult.Status -ne [DSCGetSummaryState]::Missing)
                {
                    $dscRequiredAction = [RequiredAction]::Remove
                    Write-Verbose "DscActionRequired='$dscRequiredAction'"
                    break
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                Write-Verbose "DscActionRequired='$dscRequiredAction'"
                return $dscRequiredAction
                break

            }
            default {
                $errorMessage = "Could not obtain a valid 'Ensure' value within '$($this.GetResourceName())' Test() function. Value was '$($desiredProperties.Ensure)'."
                New-InvalidOperationException -Message $errorMessage
            }
        }

        return $dscRequiredAction
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
        elseif ($RequiredAction -eq [RequiredAction]::NotFound)
        {
            return @{
                ApiUri                      = $DesiredStateProperties.ApiUri
                Pat                         = $DesiredStateProperties.Pat

                Force                       = $true

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

            # Add this to 'Force' subsequent function call
            $desiredStateParameters.Force = $true


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
            $errorMessage = "A required action of '$RequiredAction' has not been catered for in GetDesiredStateParameters() method."
            New-InvalidOperationException -Message $errorMessage
        }


        return $desiredStateParameters
    }


    hidden [System.Boolean]TestDesiredState()
    {
        return ($this.GetDscRequiredAction() -eq [RequiredAction]::None)
    }

    [System.Boolean] Test()
    {
        # TestDesiredState() will throw an exception in certain expected circumstances. Return $false if this occurs.
        try
        {
            return $this.TestDesiredState()
        }
        catch
        {
            return $false
        }
    }


    [Int32]GetPostSetWaitTimeMs()
    {
        return 2000
    }

    [void] SetToDesiredState()
    {
        [RequiredAction]$dscRequiredAction = $this.GetDscRequiredAction()
        $cacheProperties = $false

        if ($dscRequiredAction -in @([RequiredAction]::'New', [RequiredAction]::'Set', [RequiredAction]::'Remove'))
        {
            $dscCurrentStateProperties = $this.GetDscCurrentStateProperties()
            $dscDesiredStateProperties = $this.GetDscDesiredStateProperties()

            $dscRequiredActionFunctionName = $this.GetResourceFunctionName($dscRequiredAction)
            $dscDesiredStateParameters = $this.GetDesiredStateParameters($dscCurrentStateProperties, $dscDesiredStateProperties, $dscRequiredAction)

            # Set the lookup properties on the desired state object. Since it will be used to set the resource.
            if ($null -ne $dscCurrentStateProperties.LookupResult) {
                $dscDesiredStateParameters.LookupResult = $dscCurrentStateProperties.LookupResult
            }

            & $dscRequiredActionFunctionName @dscDesiredStateParameters | Out-Null
            Start-Sleep -Milliseconds $($this.GetPostSetWaitTimeMs())
        }
    }

    [void] Set()
    {
        $this.SetToDesiredState()
    }

}
