function Restart-NetUse {
  <#
    .SYNOPSIS
    Clears net use and restarts remote directory credentials.

    .EXAMPLE
    Restart-NetUse
    #>
  [CmdletBinding()]
  param()

  NET USE * /DELETE

  $commandToRun = '-noprofile -command &{Restart-Service LanmanWorkstation -Force}'

  Start-Process powershell -Verb runAs -ArgumentList $commandToRun
}
