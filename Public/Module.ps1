function Update-VoidTypeUtilities {
  <#
  .SYNOPSIS
  Update this module by pulling from Git.
  #>
  git -C "$((Get-Item $profile).Directory)\Modules\VoidTypeUtilities" pull
}

function Update-VoidTypeUtilitiesDaily {
  $vtuUpdateFile = "$env:TEMP\VoidTypeUtilities_LastUpdate.txt"
  $shouldUpdate = $false

  if (Test-Path $vtuUpdateFile) {
    $lastUpdate = Get-Content $vtuUpdateFile -ErrorAction SilentlyContinue
    if ($lastUpdate) {
      $lastUpdateDate = [DateTime]::Parse($lastUpdate)
      if ($lastUpdateDate.Date -lt (Get-Date).Date) {
        $shouldUpdate = $true
      }
    }
  } else {
    $shouldUpdate = $true
  }

  if ($shouldUpdate) {
    Write-Host "Updating VoidTypeUtilities..." -ForegroundColor Gray
    try {
      Update-VoidTypeUtilities -ErrorAction SilentlyContinue
      (Get-Date).ToString() | Set-Content $vtuUpdateFile
      Import-Module VoidTypeUtilities -Force
    } catch {
      # Silently continue if update fails
    }
  }
}

function Show-VoidTypeUtilitiesVersion {
  <#
  .SYNOPSIS
  Show the Git status of the module.
  #>
  git -C "$((Get-Item $profile).Directory)\Modules\VoidTypeUtilities" fetch
  git -C "$((Get-Item $profile).Directory)\Modules\VoidTypeUtilities" status
}
