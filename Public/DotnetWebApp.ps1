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

  Get-ChildItem -Recurse -Include *.csproj -Path $Path |
    Select-Object -ExpandProperty DirectoryName |
    Get-ChildItem -Exclude obj, bin |
    ForEach-Object {
      Get-ChildItem -Path $_.FullName -Recurse *.cs |
        ForEach-Object {
          [Microsoft.PowerShell.Commands.MatchInfo[]]$matches = $_ | Select-String -Pattern '^\s*(public|internal|private)\s(\w*\s)*class'

          if ($matches.Length -gt 0) {
            $match = $matches[0]

            if ($null -ne $match) {
              $class = $match.Line.Split('class')[1].Split(' : ')[0].Split('<')[0].Split('{')[0].Trim()
              $file = $match.Filename.split('.')[0]

              if ($class -ne $file) {
                [PSCustomObject]@{
                  FileName  = $match.Path
                  ClassName = $class
                }
              }
            }
          }
        }
      }
}

function Find-DotnetNamespaceFileNameMismatch {
  <#
      .SYNOPSIS
      Show all *.cs files where the namespace doesn't match the file path.

      .EXAMPLE
      Find-DotnetNamespaceFileNameMismatch

      .EXAMPLE
      Find-DotnetNamespaceFileNameMismatch -Path "./MyProject/"
      #>
  [CmdletBinding()]param(
    # Root path to find C# files.
    [string]$Path = "./"
  )

  Get-ChildItem -Recurse -Include *.csproj -Path $Path |
    Select-Object -ExpandProperty DirectoryName |
    Get-ChildItem -Exclude obj, bin |
    ForEach-Object {
      Get-ChildItem -Path $_.FullName -Recurse *.cs |
        ForEach-Object {
          $match = Select-String -Path $_.FullName -Pattern '^namespace ' -Raw

          if ($null -eq $match) {
            return;
          }

          $ns = $match.Split('namespace ')[1]
          $path = $_.Directory.FullName.Replace('\', '.');

          if (-not $path.Contains($ns)) {
            [PSCustomObject]@{
              FileName  = $_.FullName
              Namespace = $ns
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
    [string]$Path = "./"
  )
  New-Item -ItemType File -Path $Path -Name 'app_offline.htm'
  Start-Sleep -Seconds 2
  Remove-Item -Path "$($Path)app_offline.htm"
}

function Format-DotnetCode {
  <#
  .SYNOPSIS
    Run dotnet format and VoidCore naming convention checks.
  .EXAMPLE
    PS C:\> Format-DotnetCode
    Restarts the webapp that uses the current folder as it's root.
  #>
  [CmdletBinding()]
  param (
    # Path of the root app folder in IIS
    [string]$Path = "./"
  )

  dotnet format --fix-whitespace --fix-style warn
  Find-DotnetNamespaceFileNameMismatch
  Find-DotnetClassFileNameMismatch
}
