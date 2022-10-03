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

function cdd {
  <#
  .SYNOPSIS
  Go to dev folder. Will go to first match of a partial project name.
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
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

$getCddProjects = { (Get-ChildItem -Path $defaultDevDir -Directory).Name }

Register-ArgumentCompleter -CommandName cdd -ParameterName ProjectName -ScriptBlock $getCddProjects

function coded {
  <#
  .SYNOPSIS
  Open VSCode in project of dev folder. Will go to first match of a partial project name.
  #>
  param (
    [Parameter(Mandatory = $true)]
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

Register-ArgumentCompleter -CommandName coded -ParameterName ProjectName -ScriptBlock $getCddProjects
