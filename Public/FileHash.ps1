function Compare-FileHashToSumFile {
  <#
      .SYNOPSIS
      Compare the has of a file to the expected hash in a sum file.

      .DESCRIPTION
      Compare the has of a file to the expected hash in a sum file.
      The sum file will have a file per line in the format of "<hash> <filename>"

      .EXAMPLE
      Compare-FileHashToSumFile -Path myfile.txt -SumFilePath myfilesums.SHA256SUM

      In a folder with myfile.txt and myfilesums.SHA256SUM will compare hashes and give results.
      #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$SumFilePath,
    [string]$Algorithm = "SHA256"
  )

  $file = Get-ChildItem -Path $Path

  $expected = (Get-Content -Path $SumFilePath | Where-Object { $_ -like "*$($file.Name)" }).split()[0]

  $actual = ($file | Get-FileHash -Algorithm $Algorithm).Hash

  return $expected -ieq $actual
}

function Compare-FileHashBatch {
  <#
      .SYNOPSIS
      Compare hashes on a folder of files.

      .DESCRIPTION
      Computes hashes on a folder of files with similar names.
      The new file should have the same name as the old with something appended to the name just before the final extension.
      By default this appendage is " (1)" since that's what Windows appends to duplicate downloads.

      .EXAMPLE
      Compare-FileHashBatch

      In a folder with myfile.txt and myfile (1).txt will compare hashes and give results.

      .EXAMPLE
      Compare-FileHashBatch -ResultsCsv "results.csv" -SecondFileMarker ".new"

      In a folder with myfile.txt and myfile.new.txt will compare hashes and save results to the disk.
      #>
  [CmdletBinding()]
  param(
    [string]$Path = (Get-Location | Select-Object -ExpandProperty Path),
    [string]$SecondFileMarker = " (1)",
    [string]$ResultsCsv
  )

  $results = Get-ChildItem -Exclude "*$($SecondFileMarker).*", "*.csv", "*.ps1" -Recurse |
    ForEach-Object {
      $oldHash = Get-FileHash -Path "$($_.Name.Split('.')[-2])$($SecondFileMarker).$($_.Name.Split('.')[-1])" | Select-Object -ExpandProperty Hash
      $newHash = Get-FileHash -Path "$($_.Name)" | Select-Object -ExpandProperty Hash

      $_ | Select-Object -Property Name, @{
        Name       = "OldHash";
        Expression = { $oldHash }
      }, @{
        Name       = "NewHash";
        Expression = { $newHash }
      }, @{
        Name       = "Match";
        Expression = { $newHash -eq $oldHash }
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
