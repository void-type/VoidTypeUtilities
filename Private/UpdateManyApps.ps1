# This updates a whole folder of .NET applications.

Push-Location "~/_gitLocal/_net5"

# Try the upgrade
Get-ChildItem | ForEach-Object -Parallel {
  Push-Location $_
  Write-Host "Working on $_"

  git pull

  try {
    Push-Location -Path "src/*Web/ClientApp" -ErrorAction Stop
    npm install
    npm audit fix
    npm update
  } catch {
    Write-Warning "Skipping client app"
  } finally {
    Pop-Location
  }

  dotnet tool restore
  .\build\updateTools.ps1
  dotnet outdated -u

  Pop-Location
}

Write-Host "`n`n`n`n`n"

# Double check when all done
Get-ChildItem | ForEach-Object {
  Push-Location $_
  Write-Host "`n`nWorking on $_"

  try {
    Push-Location -Path "src/*Web/ClientApp" -ErrorAction Stop
    npm outdated
  } catch {
    Write-Warning "Skipping client app"
  } finally {
    Pop-Location
  }

  dotnet outdated

  Pop-Location
}

Pop-Location


# Just some ad-hoc helpers, can add -Parallel if needed.
# gci -Directory | foreach -Parallel { pushd $_; git pull; popd; }
# gci -Directory | foreach { pushd $_; ./build/build.ps1; if($LASTEXITCODE -ne 0) {throw "FAILED"}; popd; }
