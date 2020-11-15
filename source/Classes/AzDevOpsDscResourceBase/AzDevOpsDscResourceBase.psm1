using module ..\..\Enums\Ensure\Ensure.psm1
using module ..\..\Enums\RequiredAction\RequiredAction.psm1
using module ..\..\Classes\DscResourceBase\DscResourceBase.psm1
using module ..\..\Classes\AzDevOpsApiDscResourceBase\AzDevOpsApiDscResourceBase.psm1

# Re-defined here so it is recognised by 'Import-DscResource' (which won't post-parse the 'using' statements)
enum Ensure
{
    Present
    Absent
}

class AzDevOpsDscResourceBase : AzDevOpsApiDscResourceBase
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



    hidden [System.Management.Automation.PSObject]GetDscCurrentStateObject()
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
        $dscCurrentStateResourceObject = $(& $thisResourceGetFunctionName @getParameters)

        # If no object was returned (i.e it does not exist), create a default/empty object
        if ($null -eq $dscCurrentStateResourceObject)
        {
            return New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                Ensure = [Ensure]::Absent
            }
        }

        return $dscCurrentStateResourceObject
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
            throw "Method 'GetCurrentState()' in '$($thisType.Name)' must be overidden and called by an inheriting class."
        }
        return $null
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
        [Hashtable]$currentProperties = $this.GetDscCurrentStateProperties()
        [Hashtable]$desiredProperties = $this.GetDscDesiredStateProperties()

        [System.String[]]$dscPropertyNamesWithNoSetSupport = $this.GetDscResourcePropertyNamesWithNoSetSupport()
        [System.String[]]$dscPropertyNamesToCompare = $this.GetDscResourcePropertyNames()


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


        # Perform logic with 'Ensure' (to determine whether resource should be created or dropped (or updated, if already [Ensure]::Present but property values differ)
        $dscRequiredAction = [RequiredAction]::None

        switch ($desiredProperties.Ensure)
        {
            ([Ensure]::Present) {

                # If not already present, or different to expected/desired - return [RequiredAction]::New (i.e. Resource needs creating)
                if ($null -eq $currentProperties -or $($currentProperties.Ensure) -ne [Ensure]::Present)
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
                            throw "The '$($this.GetType().Name)', DSC Resource does not support changes for/to the '$_' property."
                            break
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
                throw "Could not obtain a valid 'Ensure' value within 'AzDevOpsProject' Test() function. Value was '$($desiredProperties.Ensure)'."
                return [RequiredAction]::Error
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


    hidden [System.Boolean]TestDesiredState()
    {
        return ($this.GetDscRequiredAction() -eq [RequiredAction]::None)
    }

    [System.Boolean] Test()
    {
        return $this.TestDesiredState()
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

    [void] Set()
    {
        $this.SetToDesiredState()
    }

}
