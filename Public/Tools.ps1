$global:vtuDefaultToolsDir = "$((Get-Item $profile).Directory)/Tools"
$global:vtuDefaultSqlPackageDir = "$($global:vtuDefaultToolsDir)/SqlPackage"
$global:vtuDefaultPsToolsDir = "$($global:vtuDefaultToolsDir)/PsTools"

function Get-ToolsSqlPackage {
  $sqlPackageExePath = "$vtuDefaultSqlPackageDir/SqlPackage.exe"

  # Migrate old installations
  if (Test-Path "$((Get-Item $profile).Directory)/SqlPackage/SqlPackage.exe") {
    Write-Host 'Migrating to tools directory...'
    Move-Item -Path "$((Get-Item $profile).Directory)/SqlPackage" -Destination $vtuDefaultSqlPackageDir
  }

  if (Test-Path -Path $sqlPackageExePath) {
    return $sqlPackageExePath
  }

  if (-not $IgnorePath) {
    [string]$pathSource = (Get-Command 'SqlPackage' -ErrorAction SilentlyContinue).Source

    if (-not [string]::IsNullOrWhiteSpace($pathSource)) {
      return $pathSource
    }
  }

  Write-Host 'Downloading SqlPackage...'

  New-Item -ItemType Directory -Path $vtuDefaultSqlPackageDir -Force -ErrorAction Ignore | Out-Null

  $sqlPackageZipPath = "$vtuDefaultSqlPackageDir/SqlPackage.zip"

  Invoke-WebRequest -Uri 'https://aka.ms/sqlpackage-windows' -OutFile $sqlPackageZipPath

  Expand-Archive -Path $sqlPackageZipPath -DestinationPath $vtuDefaultSqlPackageDir

  Remove-Item -Path $sqlPackageZipPath

  if (-not (Test-Path -Path $sqlPackageExePath)) {
    throw 'SQLPackage not found. Exiting.'
  }

  return $sqlPackageExePath
}

function Get-ToolsPsTools {
  [CmdletBinding()]
  param (
    [string]$Name = 'PsExec',
    [switch]$IgnorePath
  )

  $psExecExePath = "$vtuDefaultPsToolsDir/$($Name).exe"

  if (Test-Path -Path $psExecExePath) {
    return $psExecExePath
  }

  if (-not $IgnorePath) {
    [string]$pathSource = (Get-Command $Name -ErrorAction SilentlyContinue).Source

    if (-not [string]::IsNullOrWhiteSpace($pathSource)) {
      return $pathSource
    }
  }

  Write-Host 'Downloading PsTools...'

  New-Item -ItemType Directory -Path $vtuDefaultPsToolsDir -Force -ErrorAction Ignore | Out-Null

  $psToolsZipPath = "$vtuDefaultPsToolsDir/PsTools.zip"

  Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile $psToolsZipPath

  Expand-Archive -Path $psToolsZipPath -DestinationPath $vtuDefaultPsToolsDir

  Remove-Item -Path $psToolsZipPath

  if (-not (Test-Path -Path $psExecExePath)) {
    throw 'PsTools not found. Exiting.'
  }

  return $psExecExePath
}
