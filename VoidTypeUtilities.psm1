Get-ChildItem -Path "$PSScriptRoot/Public" -Filter "*.ps1" -Recurse |
  ForEach-Object { . $_.FullName }
