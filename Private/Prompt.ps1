# Use by adding the following to your Profile
# . "$($env:PSModulePath.Split(";")[0])/VoidTypeUtilities/Private/Prompt.ps1"
function prompt {
  $dateString = Get-Date -UFormat '+%Y-%m-%d %H:%M'
  $locationString = (Get-Item -Path (Get-Location) -Force).Name
  $promptString = "pwsh $dateString $locationString>"
  Write-Host $promptString -NoNewline -ForegroundColor Cyan
  return " "
}

Set-PSReadlineOption -BellStyle None
