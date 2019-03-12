function Connect-PsExec {
  <#
      .SYNOPSIS
      Connect a to a remote client via PSEXEC.

      .DESCRIPTION
      Uses PsExec (must be in your PATH) and connects to remote client to run a command.
      If you use a command like CMD, Powershell, or pwsh, this will open a remote terminal.
      THIS SCRIPT RUN AS AN ELEVATED USER ON THE REMOTE MACHINE!

      .EXAMPLE
      Connect-PsExec -ComputerName Server01 -Command powershell
      #>
  [CmdletBinding()]param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ComputerName,
    [Parameter(Mandatory = $true, Position = 2)]
    [string]$Command,
    [PSCredential]$Credential = (Get-Credential)
  )

  PsExec \\$ComputerName -u $Credential.UserName -p $Credential.GetNetworkCredential().Password -h $Command
}


