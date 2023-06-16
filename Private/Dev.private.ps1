$global:vtuDefaultDevDir = 'C:\dev\'

function GetCddProjects {
  param(
    $commandName,
    $parameterName,
    $wordToComplete
  )

  [string[]]$results = (Get-ChildItem -Path ($vtuDefaultDevDir + $wordToComplete + '*') -Directory).Name

  # If results weren't found with completion, add wildcard to the front.
  if ($results.Count -lt 1) {
    [string[]]$results = (Get-ChildItem -Path ($vtuDefaultDevDir + '*' + $wordToComplete + '*') -Directory).Name
  }

  return $results
}
