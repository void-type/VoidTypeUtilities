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
