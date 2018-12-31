function Get-FileHashBatch {
  <#
      .SYNOPSIS
      Compare hashes on a folder of files.

      .DESCRIPTION
      Computes hashes on a folder of files with similar names.
      The new file should have the same name as the old with " (1)" appended to the name just before the final extension.

      .EXAMPLE
      Get-FileHashBatch

      In a folder with myfile.txt and myfile (1).txt will compare hashes and give results.
      #>
  [CmdletBinding()]
  param(
    [string]$Path = (Get-Location | Select-Object -ExpandProperty Path),
    [string]$ResultsCsv
  )

  $results = Get-ChildItem -Exclude "* (1).*", "*.csv", "*.ps1" -Recurse | ForEach-Object {
    $oldHash = Get-FileHash -Path "$($_.Name.Split('.')[-2]) (1).$($_.Name.Split('.')[-1])" | Select-Object -ExpandProperty Hash
    $newHash = Get-FileHash -Path "$($_.Name)" | Select-Object -ExpandProperty Hash

    $_ | Select-Object -Property Name, @{
      Name       = "OldHash";
      Expression = {$oldHash}
    }, @{
      Name       = "NewHash";
      Expression = {$newHash}
    }, @{
      Name       = "Match";
      Expression = {$newHash -eq $oldHash}
    }
  }

  $failedResults = $results | Where-Object Match -eq $false

  if (($failedResults | Measure-Object).Count -ne 0) {
    Write-Host "Failed:"
    $failedResults
  } else {
    Write-Host "Successful!"
  }

  if (-not [string]::IsNullOrEmpty($ResultsCsv)) {
    $results | Export-Csv -Path $ResultsCsv
  }
}
