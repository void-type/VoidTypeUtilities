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
