function Get-FileVersionInfo {
  <#
      .SYNOPSIS
      Get the version info of a file.

      .DESCRIPTION
      Pulls file version info such as Product Version and File Version. These properties map
      to AssemblyInformationVersion and Version within the AssemblyInfo.cs file.

      .EXAMPLE
      Get-FileVersionInfo -Path "my.dll"
      #>
  [CmdletBinding()]
  param(
    [Parameter(
      Position = 1,
      ValuefromPipelineByPropertyName = $true
    )]
    [string]$Path,
    [Parameter(
      ValueFromPipeline = $true
    )]
    [System.IO.FileInfo]$FileInfo
  )

  if ($null -eq $FileInfo) {
    $FileInfo = Get-ChildItem -Path $Path
  }

  return [System.Diagnostics.FileVersionInfo]::GetVersionInfo($FileInfo.FullName)
}
