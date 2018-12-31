function Backup-Folder {
  <#
    .SYNOPSIS
    Clones a folder.

    .DESCRIPTION
    Clones a folder with the ability to restore from the backup.
    WARNING: this command will overwrite the destination folder, including removing extra files.

    .EXAMPLE
    Backup-Folder -Source "C:\Users\Me\Desktop\folder" -Destination "D:\Backups\folder"

    .EXAMPLE
    Backup-Folder "C:\Users\Me\Desktop\folder" "D:\Backups\folder"

    .EXAMPLE
    Backup-Folder -Source "C:\Users\Me\Desktop\folder" -Destination "D:\Backups\folder" -Restore

    Reverse the backup source and destination.
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [switch]$Restore
  )

  # Run jobs
  if ($Restore -eq $false) {
    ROBOCOPY "$Source" "$Destination" /MIR /NFL /NDL /NP /MT:32 | Out-Host
  }
  else {
    ROBOCOPY "$Destination" "$Source" /MIR /NFL /NDL /NP /MT:32 | Out-Host
  }
}
