<#
    .SYNOPSIS
        Defines a base class from which other DSC resources inherit from.
#>
class DscResourceBase
{
    hidden [System.String]GetDscResourceKey()
    {
        [System.String]$dscResourceKeyPropertyName = $this.GetDscResourceKeyPropertyName()

        if ([String]::IsNullOrWhiteSpace($dscResourceKeyPropertyName))
        {
            $errorMessage = "Cannot obtain a 'DscResourceKey' value for the '$($this.GetType().Name)' instance."
            throw (New-InvalidOperationException -Message $errorMessage)
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

            $propertyInfo.GetCustomAttributes($true) | ForEach-Object {

                if ($_.TypeId.Name -eq 'DscPropertyAttribute' -and
                    $_.Key -eq $true)
                {
                    $dscResourceKeyPropertyNames += $PropertyName
                }
            }
        }

        if ($null -eq $dscResourceKeyPropertyNames -or $dscResourceKeyPropertyNames.Count -eq 0)
        {
            $errorMessage = "Could not obtain a 'DscResourceDscKey' property for type '$($this.GetType().Name)'."
            throw (New-InvalidOperationException -Message $errorMessage)

        }
        elseif ($dscResourceKeyPropertyNames.Count -gt 1)
        {
            $errorMessage = "Obtained more than 1 property for type '$($this.GetType().Name)' that was marked as a 'Key'. There must only be 1 property on the class set as the 'Key' for DSC."
            throw (New-InvalidOperationException -Message $errorMessage)
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

            $propertyInfo.GetCustomAttributes($true) | ForEach-Object {

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
