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

  process {
    $SearchText | ForEach-Object {
      Write-Verbose "Searching $_"
      git grep "$_" $(git rev-list --reverse --all) | Write-Output
    }
  }
}

function Copy-GitCommitFiles {
  <#
      .SYNOPSIS
      Copy files changed in a specific git commit
      #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$CommitId,
    [string]$OutputDirectory = "~/Downloads/CommitCopy"
  )

  $changedFiles = git diff-tree -r --no-commit-id --name-only --diff-filter=ACMRT $CommitId

  $changedFiles |
    ForEach-Object {
      New-Item -ItemType File -Path "$OutputDirectory/$_" -Force
      Copy-Item $_ -Destination "$OutputDirectory/$_"
    }
}

function Remove-GitOldBranches {
  <#
      .SYNOPSIS
      Quick prune of git repo branches (remote cache and local)
      #>
  [CmdletBinding()]
  param (
    [Parameter()]
    [string[]]
    $OtherBranchesToIgnore
  )

  git fetch --prune

  git branch --merged |
    ForEach-Object { $_.Trim() } |
    # Doesn't start with * (current branch)
    Where-Object { $_ -notmatch '^\*' } |
    # Don't remove typical trunk branches
    Where-Object { $_ -notin 'main', 'master', 'dev', 'develop' } |
    # Don't remove specified branches
    Where-Object { $_ -notin $OtherBranchesToIgnore } |
    # Delete merged branch
    ForEach-Object { git branch -d $_ }
}
