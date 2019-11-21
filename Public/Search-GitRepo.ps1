function Search-GitRepo {
  <#
      .SYNOPSIS
      Search Git history for strings.

      .DESCRIPTION
      Uses git grep to find strings in files checked into git.

      .EXAMPLE
      Search-GitRepo -SearchText "myPassword1", "somethingSecret"

      .EXAMPLE
      $secretsArray | Search-GitRepo
      #>
  [CmdletBinding()]param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [string[]]$SearchText
  )

  Process {
    $SearchText | ForEach-Object {
      Write-Verbose "Searching $_"
      git grep "$_" $(git rev-list --reverse --all) | Write-Output
    }
  }
}
