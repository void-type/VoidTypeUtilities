# Opens $profile directory in VSCode.
function Edit-PsProfile {
  code (Get-Item $profile).Directory
}

# Runs a command on each directory in the parent specified
function Invoke-ChildDirectories {
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
