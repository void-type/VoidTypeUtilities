$global:vtuDefaultDevDir = 'C:\dev\'
$global:vtuDefaultIde = 'code'

function Edit-PsProfile {
  <#
  .SYNOPSIS
  Opens $profile directory in IDE.
  #>
  & $vtuDefaultIde (Get-Item $profile).Directory
}

function Edit-PsModules {
  <#
  .SYNOPSIS
  Opens the first $PSModulePath directory in IDE.
  #>

  $modulePath = $env:PSModulePath -split ';' | Select-Object -First 1

  & $vtuDefaultIde $modulePath
}

function Edit-PsHistory {
  & $global:vtuDefaultIde (Get-PSReadLineOption).HistorySavePath
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

  & $vtuDefaultIde $folder
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
    Get-ChildItem -Path $Path -Directory |
      ForEach-Object {
        $currentDirectory = $_

        Push-Location $currentDirectory
        Invoke-Command -ScriptBlock $DirectoryScriptBlock | Write-Host
        Pop-Location
      }
  }
}

function Get-DevProjects {
  param(
    [string]$ProjectName
  )

  [System.IO.DirectoryInfo[]]$results = Get-ChildItem -Path ($vtuDefaultDevDir + $ProjectName + '*') -Directory

  # If results weren't found with completion, add wildcard to the front.
  if ($results.Count -lt 1) {
    [System.IO.DirectoryInfo[]]$results = Get-ChildItem -Path ($vtuDefaultDevDir + '*' + $ProjectName + '*') -Directory
  }

  return $results
}

# Used for autocomplete
function Get-DevProjectNames {
  param(
    [string]$commandName,
    [string]$parameterName,
    [string]$wordToComplete
  )

  return Get-DevProjects -ProjectName $wordToComplete |
    Select-Object -ExpandProperty Name
}

# Shared logic for dev commands to resolve a project, or the parent directory if project name is empty.
function Resolve-DevPath {
  param(
    [string]$ProjectName
  )

  if ([string]::IsNullOrWhitespace($ProjectName)) {
    return $vtuDefaultDevDir
  }

  # In case the user didn't complete, we'll complete it for them.
  $ProjectDir = Get-DevProjects -ProjectName $ProjectName | Select-Object -First 1

  if ($null -eq $ProjectDir) {
    throw "No project found with name '$ProjectName' in $vtuDefaultDevDir"
  }

  return $ProjectDir.FullName
}

function cdd {
  <#
  .SYNOPSIS
  Go to dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
    [ArgumentCompleter({ Get-DevProjectNames @args })]
    [string]
    $ProjectName
  )

  Set-Location -Path (Resolve-DevPath -ProjectName $ProjectName)
}

function explored {
  explorer $global:vtuDefaultDevDir
}

function coded {
  <#
  .SYNOPSIS
  Open IDE in project of dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param (
    [Parameter()]
    [ArgumentCompleter({ Get-DevProjectNames @args })]
    [string]
    $ProjectName
  )

  & $vtuDefaultIde (Resolve-DevPath -ProjectName $ProjectName)
}

function cloned {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl,
    [Parameter(Mandatory = $false)]
    [string]$Destination
  )

  cdd

  if (-not [string]::IsNullOrWhiteSpace($Destination)) {
    git clone $RepoUrl $Destination
    coded $Destination
  } else {
    git clone $RepoUrl
    # Extract the repository name from the URL
    $repoName = $RepoUrl.TrimEnd('/') -replace '\.git$', '' -replace '^.*/', ''
    coded $repoName
  }
}

function codei {
  <#
  .SYNOPSIS
  Open IDE with specified arguments.
  #>
  [CmdletBinding()]
  param (
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
  )

  & $vtuDefaultIde @Args
}

# Only register touch function if it doesn't already exist (e.g., native Linux/Unix command)
if (-not (Get-Command -Name touch -ErrorAction SilentlyContinue)) {
  function touch {
    <#
    .SYNOPSIS
    Update the access and modification times of a file to the current time.
    If the file does not exist, it is created.
    #>
    [CmdletBinding()]
    param (
      [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
      [string[]] $Path
    )

    process {
      foreach ($file in $Path) {
        if (Test-Path -Path $file) {
          # Update the LastWriteTime and LastAccessTime to the current time
          (Get-Item $file).LastWriteTime = Get-Date
          (Get-Item $file).LastAccessTime = Get-Date
        } else {
          # Create an empty file
          New-Item -ItemType File -Path $file | Out-Null
        }
      }
    }
  }
}

