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
