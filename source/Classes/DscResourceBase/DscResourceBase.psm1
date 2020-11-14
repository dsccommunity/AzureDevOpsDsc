using module ..\..\Enums\Ensure\Ensure.psm1
using module ..\..\Enums\RequiredAction\RequiredAction.psm1

$script:azureDevOpsDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\AzureDevOpsDsc.Common'
Import-Module -Name $script:azureDevOpsDscCommonModulePath


class DscResourceBase
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
