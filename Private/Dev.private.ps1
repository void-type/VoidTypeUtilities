$global:vtuDefaultDevDir = 'C:\dev\'

function GetCddProjects {
  param(
    $commandName,
    $parameterName,
    $wordToComplete
  )

  return (Get-ChildItem -Path ($vtuDefaultDevDir + $wordToComplete + '*') -Directory).Name
}
