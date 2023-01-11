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
    [string[]]$Path
  )

  process {
    [System.IO.FileInfo[]] $files = Get-ChildItem -Path $Path

    foreach ($f in $files) {
      $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($f.FullName)
      Write-Output $version
    }
  }
}
