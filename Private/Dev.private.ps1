$defaultDevDir = 'C:\dev\'

function GetCddProjects {
  param(
    $commandName,
    $parameterName,
    $wordToComplete
  )

  return (Get-ChildItem -Path ($defaultDevDir + $wordToComplete + '*') -Directory).Name
}
