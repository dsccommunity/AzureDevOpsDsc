
class DscResourceBase
{
    hidden [System.String]GetDscResourceKey()
    {
        [System.String]$dscResourceKeyPropertyName = $this.GetDscResourceKeyPropertyName()

        if ([String]::IsNullOrWhiteSpace($dscResourceKeyPropertyName))
        {
            throw "Cannot obtain a 'DscResourceKey' value for the '$($this.GetType().Name)' instance."
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
            Write-Error "Could not obtain a 'DscResourceDscKey' property for type '$($this.GetType().Name)'."
            return [string]::Empty

        }
        elseif ($dscResourceKeyPropertyNames.Count -gt 1)
        {
            Write-Error "Obtained more than 1 property for type '$($this.GetType().Name)' that was marked as a 'Key'. There must only be 1 property on the class set as the 'Key' for DSC."
            return [string]::Empty
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
