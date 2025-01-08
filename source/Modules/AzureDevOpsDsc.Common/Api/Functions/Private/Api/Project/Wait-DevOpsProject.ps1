<#
.SYNOPSIS
    Waits for a project to be created in Azure DevOps.

.DESCRIPTION
    The Wait-DevOpsProject function waits for a project to be created in Azure DevOps. It checks the status of the project creation and waits until the project is either created successfully or fails to be created.

.PARAMETER OrganizationName
    The name of the Azure DevOps organization.

.PARAMETER ProjectURL
    The URL of the project to wait for.

.PARAMETER ApiVersion
    The version of the Azure DevOps API to use. If not specified, the default API version will be used.

.EXAMPLE
    Wait-DevOpsProject -OrganizationName "MyOrg" -ProjectURL "https://dev.azure.com/MyOrg/MyProject"

.NOTES
    Author: Michael Zanatta
    Date: 2025-01-06
#>

Function Wait-DevOpsProject
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [string]$ProjectURL,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri    = '{0}' -f $ProjectURL
        Method = "GET"
    }

    Write-Verbose "[Wait-DevOpsProject] URI: $($params.URI)"

    # Loop until the project is created
    $counter = 0
    do
    {
        Write-Verbose "[Wait-DevOpsProject] Sending request to check project status..."
        $response = Invoke-AzDevOpsApiRestMethod @params
        $project = $response

        # Check the status of the project
        switch ($response.status)
        {
            'creating' {
                Write-Verbose "[Wait-DevOpsProject] Project is still being created..."
                Start-Sleep -Seconds 5
            }
            'wellFormed' {
                Write-Verbose "[Wait-DevOpsProject] Project has been created successfully."
                break
            }
            'failed' {
                Write-Error "[Wait-DevOpsProject] Project creation failed: $response"
                break
            }
            'notSet' {
                Write-Error "[Wait-DevOpsProject] Project creation status is not set: $response"
                break
            }
            default {
                # Still creating
                Write-Verbose "[Wait-DevOpsProject] Project is still being created (default case)..."
                Start-Sleep -Seconds 5
            }
        }

        # Increment the counter
        $counter++

    } while ($counter -lt 10)

    if ($counter -ge 10)
    {
        Write-Error "[Wait-DevOpsProject] Timed out waiting for project to be created."
    }

}
