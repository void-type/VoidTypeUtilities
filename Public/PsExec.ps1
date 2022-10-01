function Connect-PsExec {
  <#
      .SYNOPSIS
      Connect a to a remote client via PSEXEC.

      .DESCRIPTION
      Uses PsExec (must be in your PATH) and connects to remote client to run a command.
      If you use a command like CMD, Powershell, or pwsh, this will open a remote terminal.
      THIS SCRIPT RUN AS AN ELEVATED USER ON THE REMOTE MACHINE!

      .EXAMPLE
      Connect-PsExec -ComputerName Server01

      Opens a powershell prompt for Server01.

      .EXAMPLE
      Connect-PsExec -ComputerName Server01 -Command cmd -Credential $cred

      Opens a CMD prompt for Server01 with the supplied credentials.
      #>
  [CmdletBinding()]param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ComputerName,
    [Parameter(Position = 2)]
    [string]$Command = "powershell",
    [PSCredential]$Credential = (Get-Credential -Message "Enter credentials (DOMAIN\AdminUser)")
  )

  PsExec \\$ComputerName -u $Credential.UserName -p $Credential.GetNetworkCredential().Password -h $Command
}


