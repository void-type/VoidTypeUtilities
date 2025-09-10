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

function Get-GitCommitFileNames {
  <#
      .SYNOPSIS
      List the names of files that were changed in a specific git commit or commit range (eg: 80f94e0~1..f707969)
      #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$CommitId,
    [switch]$Deleted
  )

  $filter = if ($Deleted) { 'D' } else { 'ACMRT' }

  return git diff-tree -r --no-commit-id --name-only --diff-filter=$filter $CommitId
}

function Copy-GitCommitFiles {
  <#
      .SYNOPSIS
      Copy files (the current state of them) that were changed in a specific git commit or commit range (eg: 80f94e0~1..f707969)
      #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$CommitId,
    [string]$OutputDirectory = '~/Downloads/CommitCopy-{CommitId}'
  )

  $OutputDirectory = $OutputDirectory -replace '{CommitId}', $CommitId

  [string[]]$changedFiles = Get-GitCommitFileNames $CommitId

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

  # The following branches' upstream has been removed
  $staleBranches = git branch -vv | Where-Object { $_ -match '\[.*: gone\]' } | ForEach-Object { ($_ -split '\s+')[1] }

  # if there are any stale branch prompt to delete them
  if ($staleBranches.Count -eq 0) {
    return
  }

  Write-Host "The following branches have 'gone' upstream, but we cannot tell if they've been merged:" -ForegroundColor Yellow
  $staleBranches | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }

  $confirmation = Read-Host "Do you want to delete these branches? (y/n)"
  if ($confirmation -eq 'y') {
    foreach ($branch in $staleBranches) {
      git branch -D $branch
    }
    return
  }
}

function Show-GitStatuses {
  cdd

  Invoke-ChildDirectories {
    $currentDirectory = Get-Location | Get-Item | Select-Object -ExpandProperty Name

    $gitStatus = git status --porcelain 2>$null

    if ($gitStatus) {
      # Count different types of changes
      $added = ($gitStatus | Where-Object { $_ -match '^A' }).Count
      $modified = ($gitStatus | Where-Object { $_ -match '^M' }).Count
      $deleted = ($gitStatus | Where-Object { $_ -match '^D' }).Count
      $renamed = ($gitStatus | Where-Object { $_ -match '^R' }).Count
      $untracked = ($gitStatus | Where-Object { $_ -match '^\?\?' }).Count
      # $staged = ($gitStatus | Where-Object { $_ -match '^[AMDRC]' }).Count
      # $unstaged = ($gitStatus | Where-Object { $_ -match '^.[MD]' }).Count

      # Get ahead/behind info
      $aheadBehind = git rev-list --left-right --count HEAD...@ { u } 2>$null
      if ($aheadBehind) {
        $ahead = ($aheadBehind -split '\s+')[0]
        $behind = ($aheadBehind -split '\s+')[1]
      } else {
        $ahead = 0
        $behind = 0
      }

      # Build summary string with colors
      $summary = @()
      if ($behind -gt 0) { $summary += "↓$behind" }
      if ($ahead -gt 0) { $summary += "↑$ahead" }
      if ($added -gt 0) { $summary += @{ Text = 'A'; Number = $added; Color = 'Green' } }
      if ($modified -gt 0) { $summary += @{ Text = 'M'; Number = $modified; Color = 'Yellow' } }
      if ($deleted -gt 0) { $summary += @{ Text = 'D'; Number = $deleted; Color = 'Red' } }
      if ($renamed -gt 0) { $summary += @{ Text = 'R'; Number = $renamed; Color = 'Cyan' } }
      if ($untracked -gt 0) { $summary += @{ Text = 'U'; Number = $untracked; Color = 'Green' } }

      if ($summary.Count -gt 0) {
        Write-Host "$currentDirectory " -NoNewline
        Write-Host ' [' -NoNewline -ForegroundColor Gray

        $isFirst = $true
        foreach ($item in $summary) {
          if (-not $isFirst) { Write-Host ' ' -NoNewline }

          if ($item -is [hashtable]) {
            Write-Host $item.Number -NoNewline
            Write-Host $item.Text -NoNewline -ForegroundColor $item.Color
          } else {
            Write-Host $item -NoNewline -ForegroundColor Yellow
          }
          $isFirst = $false
        }

        Write-Host ']' -ForegroundColor Gray
      }
    }
  }

  Pop-Location
}
