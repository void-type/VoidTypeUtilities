. "$PSScriptRoot/../Private/Dev.private.ps1"

function Edit-PsProfile {
  <#
  .SYNOPSIS
  Opens $profile directory in VSCode.
  #>
  code (Get-Item $profile).Directory
}

function Edit-PsModules {
  <#
  .SYNOPSIS
  Opens the first $PSModulePath directory in VSCode.
  #>

  $modulePath = $env:PSModulePath -split ':' | Select-Object -First 1

  code $modulePath
}

function Edit-DotnetUserSecrets {
  <#
  .SYNOPSIS
  Opens .NET UserSecrets directory.
  #>

  if ($IsLinux) {
    $folder = "$HOME/.microsoft/usersecrets/"
  } elseif ($IsMacOS) {
    $folder = "$HOME/Library/Application Support/dotnet/usersecrets/"
  } else {
    # Windows
    $folder = "$env:APPDATA\microsoft\UserSecrets\"
  }

  if (-not(Test-Path -Path $folder)) {
    New-Item -ItemType Directory $folder
  }

  code $folder
}

# Runs a command on each directory in the parent specified
function Invoke-ChildDirectories {
  <#
  .SYNOPSIS
  Runs a command on each directory in the parent specified
  #>
  [CmdletBinding()]
  param (
    [Parameter()]
    [string] $Path = './',
    [Parameter(Mandatory = $true, Position = 1)]
    [scriptblock] $DirectoryScriptBlock
  )

  process {
    Get-ChildItem -Path $Path |
      ForEach-Object {
        $currentDirectory = $_

        Push-Location $currentDirectory
        Invoke-Command -ScriptBlock $DirectoryScriptBlock | Write-Host
        Pop-Location
      }
  }
}

function cdd {
  <#
  .SYNOPSIS
  Go to dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
    [ArgumentCompleter({ GetCddProjectNames @args })]
    [string]
    $ProjectName
  )

  Set-Location -Path (ResolveCddPath -ProjectName $ProjectName)
}

function coded {
  <#
  .SYNOPSIS
  Open VSCode in project of dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param (
    [Parameter()]
    [ArgumentCompleter({ GetCddProjectNames @args })]
    [string]
    $ProjectName
  )

  code (ResolveCddPath -ProjectName $ProjectName)
}
