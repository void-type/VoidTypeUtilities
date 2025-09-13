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
    # Source Directory (drive:\path or \\server\share\path).
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ })]
    [string]$Source,
    # The destination folder. This folder will be created if it doesn't exist.
    # Destination Dir (drive:\path or \\server\share\path).
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    # File(s) to copy (names/wildcards: default is "*.*").
    [string[]]$File,
    # Directories to exclude from the copy
    [string[]]$ExcludeDirectories,
    # Reverses the order of source and destination
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

  foreach ($f in $File) {
    $roboCopyArgs += $f
  }

  if ($ExcludeDirectories) {
    $roboCopyArgs += '/XD'
    foreach ($dir in $ExcludeDirectories) {
      $roboCopyArgs += $dir
    }
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
    $FolderB,

    [switch]
    $ByHash
  )

  function GetFileInfos {
    param (
      [string] $FolderPath
    )

    if (-not(Test-Path $FolderPath)) {
      throw "Path not found '$FolderPath'"
    }

    Push-Location $FolderPath

    $fileInfos = Get-ChildItem -Path './' -Recurse -File |
      ForEach-Object {
        $filePath = Resolve-Path -Path $_ -Relative

        $fileInfo = [PSCustomObject]@{
          Path = $filePath
          Hash = $null
        }

        if ($ByHash) {
          $fileInfo.Hash = (Get-FileHash -Path $_ -Algorithm SHA256).Hash
        }

        return $fileInfo
      }

    Pop-Location

    return $fileInfos
  }

  function GetEqualityString {
    param (
      [PSCustomObject]$FileInfo
    )

    if ($ByHash) {
      return $FileInfo.Path + '|' + $FileInfo.Hash

    } else {
      return $FileInfo.Path
    }
  }

  function CompareFileInfos {
    param (
      [PSCustomObject[]]$A,
      [PSCustomObject[]]$B
    )

    [string[]] $itemsB = $B | ForEach-Object { return GetEqualityString -FileInfo $_ }

    return $A | Where-Object { (GetEqualityString -FileInfo $_) -notin $itemsB }
  }

  $filesA = GetFileInfos -FolderPath $FolderA
  $filesB = GetFileInfos -FolderPath $FolderB

  Write-Host 'Missing in B'
  CompareFileInfos -A $filesA -B $filesB | Format-Table

  Write-Host

  Write-Host 'Extra in B'
  CompareFileInfos -A $filesB -B $filesA | Format-Table
}
