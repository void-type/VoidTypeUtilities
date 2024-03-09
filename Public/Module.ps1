function Update-VoidTypeUtilities {
  <#
  .SYNOPSIS
  Update this module by pulling from Git.
  #>
  git -C "$((Get-Item $profile).Directory)\Modules\VoidTypeUtilities" pull
}

function Show-VoidTypeUtilitiesVersion {
  <#
  .SYNOPSIS
  Show the Git status of the module.
  #>
  git -C "$((Get-Item $profile).Directory)\Modules\VoidTypeUtilities" fetch
  git -C "$((Get-Item $profile).Directory)\Modules\VoidTypeUtilities" status
}
