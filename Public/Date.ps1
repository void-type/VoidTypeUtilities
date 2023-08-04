function Get-TimeStampCompact {
  [CmdletBinding()]
  param (
  )

  Get-Date -Format "yyyyMMdd_HHmmss"
}
