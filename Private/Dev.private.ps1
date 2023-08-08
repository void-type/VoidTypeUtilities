$global:vtuDefaultDevDir = 'C:\dev\'

function GetCddProjects {
  param(
    [string]$ProjectName
  )

  [System.IO.DirectoryInfo[]]$results = Get-ChildItem -Path ($vtuDefaultDevDir + $ProjectName + '*') -Directory

  # If results weren't found with completion, add wildcard to the front.
  if ($results.Count -lt 1) {
    [System.IO.DirectoryInfo[]]$results = Get-ChildItem -Path ($vtuDefaultDevDir + '*' + $ProjectName + '*') -Directory
  }

  return $results
}

# Used for autocomplete
function GetCddProjectNames {
  param(
    [string]$commandName,
    [string]$parameterName,
    [string]$wordToComplete
  )

  return GetCddProjects -ProjectName $wordToComplete |
    Select-Object -ExpandProperty Name
}

# Shared logic for cdd commands to resolve a project, or the parent directory if project name is empty.
function ResolveCddPath {
  param(
    [string]$ProjectName
  )

  if ([string]::IsNullOrWhitespace($ProjectName)) {
    return $vtuDefaultDevDir
  }

  # In case the user didn't compelete, we'll complete it for them.
  $ProjectDir = GetCddProjects -ProjectName $ProjectName | Select-Object -First 1

  if ($null -eq $ProjectDir) {
    throw "No project found with name '$ProjectName' in $vtuDefaultDevDir"
  }

  return $ProjectDir.FullName
}
