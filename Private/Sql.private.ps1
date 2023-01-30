function Get-SqlPackage {
  $sqlPackageExePath = "$SqlPackageDir/SqlPackage.exe"

  if (Test-Path -Path $sqlPackageExePath) {
    return $sqlPackageExePath
  }

  Write-Host "Downloading SqlPackage..."

  New-Item -ItemType Directory -Path $SqlPackageDir -Force -ErrorAction Ignore | Out-Null

  $sqlPackageZipPath = "$SqlPackageDir/SqlPackage.zip"

  Invoke-WebRequest -Uri "https://aka.ms/sqlpackage-windows" -OutFile $sqlPackageZipPath

  Expand-Archive -Path $sqlPackageZipPath -DestinationPath $SqlPackageDir

  Remove-Item -Path $sqlPackageZipPath

  return $sqlPackageExePath
}
