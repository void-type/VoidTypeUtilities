function Edit-UserProfile {
  & $global:vtuDefaultIde $env:USERPROFILE
}

function Edit-PsProfile {
  <#
  .SYNOPSIS
  Opens $profile directory in IDE.
  #>
  & $vtuDefaultIde (Get-Item $profile).Directory
}

function Edit-PsModules {
  <#
  .SYNOPSIS
  Opens the first $PSModulePath directory in IDE.
  #>

  $modulePath = $env:PSModulePath -split ';' | Select-Object -First 1

  & $vtuDefaultIde $modulePath
}

function Edit-PsHistory {
  & $global:vtuDefaultIde (Get-PSReadLineOption).HistorySavePath
}
