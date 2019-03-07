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

  $expected = (Get-Content -Path $SumFilePath | Where-Object {$_ -like "*$($file.Name)"}).split()[0]

  $actual = ($file | Get-FileHash -Algorithm $Algorithm).Hash

  return $expected -ieq $actual
}
