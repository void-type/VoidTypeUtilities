function Backup-Folder {
  <#
    .SYNOPSIS
    Clones a folder. Note that this will delete any files from the destination that don't exist in the source unless you use the NoDelete flag!

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
    # The source folder. Must exist.
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ })]
    [string]$Source,
    # The destination folder. This folder will be created if it doesn't exist.
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    # Reverses the order of souce and destination
    [switch]$Restore,
    # Disables the /MIR flag and prevent deletion of extra files.
    [switch]$NoDelete
  )

  $roboCopyArgs = @()

  if ($Restore -eq $false) {
    $roboCopyArgs += $Source
    $roboCopyArgs += $Destination
  } else {
    $roboCopyArgs += $Destination
    $roboCopyArgs += $Source
  }

  if ($NoDelete -eq $false) {
    $roboCopyArgs += '/MIR'
  }

  $roboCopyArgs += @(
    '/NFL'
    '/NDL'
    '/NP'
    '/MT:32'
  )

  Robocopy.exe $roboCopyArgs | Write-Output
}

function Compare-Folders {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $FolderA,

    [Parameter(Mandatory = $true)]
    [string]
    $FolderB
  )

  Push-Location $FolderA
  [string[]] $filesA = Get-ChildItem -Path $FolderA -Recurse | ForEach-Object { Resolve-Path -Relative $_ }
  Pop-Location

  Push-Location $FolderB
  [string[]] $filesB = Get-ChildItem -Path $FolderB -Recurse | ForEach-Object { Resolve-Path -Relative $_ }
  Pop-Location

  Write-Host 'Missing in B'
  $filesA | Where-Object { $_ -notin $filesB }
  Write-Host
  Write-Host 'Extra in B'
  $filesB | Where-Object { $_ -notin $filesA }
}
