$global:vtuDefaultSqlServer = '(LocalDb)\MSSQLLocalDB'
$global:vtuDefaultSqlConnectionStringOptions =  'Integrated Security=True;Persist Security Info=False;Connect Timeout=60;Encrypt=True;TrustServerCertificate=True;'
$global:vtuDefaultSqlPackageDir = "$((Get-Item $profile).Directory)/SqlPackage"

function Get-SqlPackage {
  $sqlPackageExePath = "$vtuDefaultSqlPackageDir/SqlPackage.exe"

  if (Test-Path -Path $sqlPackageExePath) {
    return $sqlPackageExePath
  }

  Write-Host "Downloading SqlPackage..."

  New-Item -ItemType Directory -Path $vtuDefaultSqlPackageDir -Force -ErrorAction Ignore | Out-Null

  $sqlPackageZipPath = "$vtuDefaultSqlPackageDir/SqlPackage.zip"

  Invoke-WebRequest -Uri "https://aka.ms/sqlpackage-windows" -OutFile $sqlPackageZipPath

  Expand-Archive -Path $sqlPackageZipPath -DestinationPath $vtuDefaultSqlPackageDir

  Remove-Item -Path $sqlPackageZipPath

  if (-not (Test-Path -Path $sqlPackageExePath)) {
    throw "SQLPackage not found. Exiting."
  }

  return $sqlPackageExePath
}
