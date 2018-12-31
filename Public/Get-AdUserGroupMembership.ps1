function Get-AdUserGroupMembership {
  <#
    .SYNOPSIS
    Get group membership of an AD user when AdPrincipalMembership doesn't work.

    .EXAMPLE
    Get-AdUserGroupMembership -Identity AdminContoso02

    .Example
    Get-AdUserGroupMembership AdminContoso02
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string] $Identity
  )

  ([ADSISEARCHER]"samaccountname=$($Identity)").FindOne().Properties["memberof"]
}
