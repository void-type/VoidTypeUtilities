function Get-DotnetWebAppLogs {
  <#
      .SYNOPSIS
      Show all webAppLogs from a directory.

      .EXAMPLE
      Get-DotnetWebLogs

      .EXAMPLE
      Get-DotnetWebLogs -Path "\\app2\webAppLogsProd\App_Net" -ExcludeInfo
      #>
  [CmdletBinding()]param(
    # Path where the app log files are stored.
    [string]$Path = "./",

    # Exclude informational
    [switch]$ExcludeInfo
  )

  $logs = Get-ChildItem -Path $Path |
    Get-Content |
    Where-Object { $_ -notlike "*Starting web host." }

  if ($ExcludeInfo) {
    $logs = $logs | Where-Object { $_ -notlike '*`[INF`]*' }
  }

  return $logs
}

function Find-DotnetClassFileNameMismatch {
  <#
      .SYNOPSIS
      Show all *.cs files where the top class name doesn't match the file name.

      .EXAMPLE
      Find-DotnetClassFileNameMismatch

      .EXAMPLE
      Find-DotnetClassFileNameMismatch -Path "./MyProject/"
      #>
  [CmdletBinding()]param(
    # Root path to find C# files.
    [string]$Path = "./"
  )

  Get-ChildItem -Include *.cs -Recurse -Path $Path |
    ForEach-Object {
      [Microsoft.PowerShell.Commands.MatchInfo[]]$matches = $_ | Select-String -Pattern 'public\s(\w*\s)*class'

      if ($matches.Length -gt 0) {
        $match = $matches[0]

        if ($null -ne $match) {
          $class = $match.Line.Split('class')[1].Split(' : ')[0].Split('<')[0].Split('{')[0].Trim()
          $file = $match.filename.split('.')[0]

          if ($class -ne $file) {
            [PSCustomObject]@{
              FileName  = $file
              ClassName = $class
            }
          }
        }
      }
    }
}

function Restart-DotnetWebApp {
  <#
  .SYNOPSIS
    Restart an IIS webapp by adding an removing an app_offline.htm file.
  .EXAMPLE
    PS C:\> Restart-DotnetWebApp
    Restarts the webapp that uses the current folder as it's root.
  #>
  [CmdletBinding()]
  param (
    # Path of the root app folder in IIS
    [string]$Path = (Get-Location | Select-Object -ExpandProperty Path)
  )
  New-Item -ItemType File -Name 'app_offline.htm'
  Start-Sleep -Seconds 2
  Remove-Item -Path 'app_offline.htm'
}
