function Remove-NodeModules {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string[]]
    $Path
  )

  begin {
    $paths = [System.Collections.Generic.List[string]]::new()
  }
  process {
    $paths.AddRange($Path)
  }
  end {
    $dirs = Get-ChildItem -Path $paths -Directory -Recurse -Filter 'node_modules' |
      Sort-Object { $_.FullName.Length }

    $topLevelDirs = [System.Collections.Generic.List[System.IO.DirectoryInfo]]::new()

    foreach ($dir in $dirs) {
      $isNested = $topLevelDirs | Where-Object { $dir.FullName.StartsWith("$($_.FullName)\", [StringComparison]::OrdinalIgnoreCase) }

      if (-not $isNested) {
        $topLevelDirs.Add($dir)
      }
    }

    $dirs = $topLevelDirs

    if ($dirs.Count -eq 0) {
      Write-Warning 'No node_modules directories found in the given path(s).'
      return
    }

    foreach ($dir in $dirs) {
      Write-Host "Removing: $($dir.FullName)"
      Remove-Item -Path $dir.FullName -Recurse -Force
    }
  }
}

function Remove-NodePackageLocks {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string[]]
    $Path,

    [switch]
    $Regenerate
  )

  begin {
    $paths = [System.Collections.Generic.List[string]]::new()
  }
  process {
    $paths.AddRange($Path)
  }
  end {
    $lockFileNames = 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml'
    $excludedDirs = '\\node_modules\\', '\\bin\\', '\\obj\\'

    $files = Get-ChildItem -Path $paths -File -Recurse -Include $lockFileNames |
      Where-Object {
        $fullName = $_.FullName
        -not ($excludedDirs | Where-Object { $fullName -match $_ })
      }

    if ($files.Count -eq 0) {
      Write-Warning 'No package lock files found in the given path(s).'
      return
    }

    foreach ($file in $files) {
      Write-Host "Removing: $($file.FullName)"
      Remove-Item -Path $file.FullName -Force

      if ($Regenerate) {
        Push-Location -Path $file.DirectoryName
        try {
          switch ($file.Name) {
            'package-lock.json' { Write-Host "Regenerating: $($file.FullName) (npm install)"; npm install }
            'yarn.lock' { Write-Host "Regenerating: $($file.FullName) (yarn install)"; yarn install }
            'pnpm-lock.yaml' { Write-Host "Regenerating: $($file.FullName) (pnpm install)"; pnpm install }
          }
        }
        finally {
          Pop-Location
        }
      }
    }
  }
}
