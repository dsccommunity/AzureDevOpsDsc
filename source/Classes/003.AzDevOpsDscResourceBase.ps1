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

    [DscProperty(NotConfigurable)]
    [System.Collections.Generic.List[DscResourceReason]] $Reasons

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
        Wait-Debugger
        return $(& $thisResourceGetFunctionName @GetParameters)
    }


    hidden [HashTable]GetDscCurrentStateObject()
    {
        # Declare the result hashtable
        $props = @{
            GroupName = $this.GroupName
            GroupDisplayName = $this.GroupDisplayName
            GroupDescription = $this.GroupDescription
            Ensure = [Ensure]::Absent
        }

        $getParameters      = $this.GetDscCurrentStateObjectGetParameters()
        $props.LookupResult = $this.GetDscCurrentStateResourceObject($getParameters)
        $props.Reasons      = $props.LookupResult.Reasons
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
        $cacheProperties = $false

        [Hashtable]$currentProperties = $this.GetDscCurrentStateProperties()
        [Hashtable]$desiredProperties = $this.GetDscDesiredStateProperties()

        [System.String[]]$dscPropertyNamesWithNoSetSupport = $this.GetDscResourcePropertyNamesWithNoSetSupport()
        [System.String[]]$dscPropertyNamesToCompare = $this.GetDscResourcePropertyNames()

        #
        # Test if currentProperties contains a hashtable containing 'Current', 'Cache' and 'Status' properties
        if ($currentProperties -is [hashtable])
        {
            if ($currentProperties.Keys -contains 'Current' -and
                $currentProperties.Keys -contains 'Cache' -and
                $currentProperties.Keys -contains 'Status')
            {
                $cacheProperties = $true
            }
        }

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


        switch ($desiredProperties.Ensure)
        {
            ([Ensure]::Present) {

                # If not already present, return [RequiredAction]::New (i.e. Resource needs creating)
                if ($cacheProperties)
                {
                    if ($cacheProperties.Status -eq 'NotFound')
                    {
                        $dscRequiredAction = [RequiredAction]::New
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }

                    if ($cacheProperties.Status -eq 'Changed')
                    {
                        $dscRequiredAction = [RequiredAction]::Set
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }
                    return $dscRequiredAction
                }

                # If not already present, or different to expected/desired - return [RequiredAction]::New (i.e. Resource needs creating)
                if (($null -eq $currentProperties) -or ($($currentProperties.Ensure) -ne [Ensure]::Present))
                {
                    $dscRequiredAction = [RequiredAction]::New
                    Write-Verbose "DscActionRequired='$dscRequiredAction'"
                    break
                }

                # Changes made by DSC to the following properties are unsupported by the resource (other than when creating a [RequiredAction]::New resource)
                if ($dscPropertyNamesWithNoSetSupport.Count -gt 0)
                {
                    $dscPropertyNamesWithNoSetSupport | ForEach-Object {

                        if ($($currentProperties[$_].ToString()) -ne $($desiredProperties[$_].ToString()))
                        {
                            $errorMessage = "The '$($this.GetType().Name)', DSC Resource does not support changes for/to the '$_' property."
                            New-InvalidOperationException -Message $errorMessage
                        }
                    }
                }

                # Compare all properties ('Current' vs 'Desired')
                if ($dscPropertyNamesToCompare.Count -gt 0)
                {
                    $dscPropertyNamesToCompare | ForEach-Object {

                        if ($($currentProperties."$_") -ne $($desiredProperties."$_"))
                        {
                            Write-Verbose "DscPropertyValueMismatch='$_'"
                            $dscRequiredAction = [RequiredAction]::Set
                        }
                    }

                    if ($dscRequiredAction -eq [RequiredAction]::Set)
                    {
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }
                }

                # Otherwise, no changes to make (i.e. The desired state is already achieved)
                return $dscRequiredAction
                break
            }
            ([Ensure]::Absent) {

                # If not already present, return [RequiredAction]::New (i.e. Resource needs creating)
                if ($cacheProperties)
                {
                    if ($cacheProperties.Status -eq 'NotFound')
                    {
                        $dscRequiredAction = [RequiredAction]::None
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }
                    if ($cacheProperties.Status -eq 'Changed')
                    {
                        $dscRequiredAction = [RequiredAction]::Remove
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }
                    if ($cacheProperties.Status -eq 'Unchanged')
                    {
                        $dscRequiredAction = [RequiredAction]::Remove
                        Write-Verbose "DscActionRequired='$dscRequiredAction'"
                        break
                    }
                    return $dscRequiredAction
                }

                # If currently/already present - return $false (i.e. state is incorrect)
                if ($null -ne $currentProperties -and $currentProperties.Ensure -ne [Ensure]::Absent)
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
        elseif ($RequiredAction -eq [RequiredAction]::Remove)
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

            & $dscRequiredActionFunctionName @dscDesiredStateParameters | Out-Null
            Start-Sleep -Milliseconds $($this.GetPostSetWaitTimeMs())
        }
    }

    [void] Set()
    {
        $this.SetToDesiredState()
    }

}
