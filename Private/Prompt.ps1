# Use by adding the following to your Profile
# . "$($env:PSModulePath.Split(";")[0])/VoidTypeUtilities/Private/Prompt.ps1"
function prompt {
  $color = if ($null -ne $VC_PreferredPromptColor) { $VC_PreferredPromptColor } else { 'Cyan' }
  $dateString = Get-Date -UFormat '+%Y-%m-%d %H:%M'
  $locationString = (Get-Item -Path (Get-Location) -Force).Name
  $promptString = "pwsh $dateString $locationString>"
  Write-Host $promptString -NoNewline -ForegroundColor $color
  return " "
}

Set-PSReadLineOption -BellStyle None
