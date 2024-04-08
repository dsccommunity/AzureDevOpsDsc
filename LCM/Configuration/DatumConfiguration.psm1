

function New-TemporaryDirectory
{
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

function Clone-DatumConfiguration
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$DatumURLConfigu,

        [Parameter(Mandatory=$true)]
        [string]$DestinationPath
    )

    $new = New-TemporaryDirectory

    git clone $GitURL $new.Path

}
