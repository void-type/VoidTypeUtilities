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
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [System.IO.FileInfo[]]$Path
  )

  process {
    foreach ($p in $Path) {
      $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($p.FullName)
      Write-Output $version
    }
  }
}
