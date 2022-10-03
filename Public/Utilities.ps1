function Edit-PsProfile {
  <#
  .SYNOPSIS
  Opens $profile directory in VSCode.
  #>
  code (Get-Item $profile).Directory
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
        $currentDirectory = $_;

        Push-Location $currentDirectory;
        Invoke-Command -ScriptBlock $DirectoryScriptBlock | Write-Host
        Pop-Location
      }
  }
}

$defaultDevDir = 'C:\dev\'

function GetCddProjects {
  param(
    $commandName,
    $parameterName,
    $wordToComplete
  )

  return (Get-ChildItem -Path ($defaultDevDir + $wordToComplete + '*') -Directory).Name
}

function cdd {
  <#
  .SYNOPSIS
  Go to dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
    [ArgumentCompleter({ GetCddProjects @args })]
    [string]
    $ProjectName,
    [Parameter()]
    [string]
    $DevDir = $defaultDevDir
  )

  if ([string]::IsNullOrWhitespace($ProjectName)) {
    Set-Location -Path $DevDir
    return;
  }

  $findPath = (Get-ChildItem -Path ($DevDir + $ProjectName + '*') -Directory | Select-Object -First 1).FullName

  if ([string]::IsNullOrWhitespace($findPath)) {
    Write-Error "No project found with name '$ProjectName' in $DevDir"
    return;
  }

  Set-Location -Path $findPath
}

function coded {
  <#
  .SYNOPSIS
  Open VSCode in project of dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ArgumentCompleter({ GetCddProjects @args })]
    [string]
    $ProjectName,
    [Parameter()]
    [string]
    $DevDir = $defaultDevDir
  )

  $findPath = (Get-ChildItem -Path ($DevDir + $ProjectName + '*') -Directory | Select-Object -First 1).FullName

  if ([string]::IsNullOrWhitespace($findPath)) {
    Write-Error "No project found with name '$ProjectName' in $DevDir"
    return;
  }

  code $findPath
}
