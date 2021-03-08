function Get-AdUserGroups {
  <#
    .SYNOPSIS
    Get the groups that a user belongs to when Get-ADPrincipalGroupMembership doesn't work.

    .EXAMPLE
    Get-AdUserGroups -Identity AdminContoso02

    .EXAMPLE
    Get-AdUserGroups AdminContoso02
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $Identity
  )

  ([ADSISEARCHER]"samaccountname=$($Identity)").FindOne().Properties["memberof"]
}

function Show-AdGroupMembersReport {
  <#
    .SYNOPSIS
    Show users from multiple groups by using a filter. Useful for auditing groups that control permissions to an app.

    .EXAMPLE
    Show-AdGroupMembershipReport -GroupNameFilter 'myApp*'

    Shows a text report of users from myAppAdmins, myAppUsers, etc...
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $GroupNameFilter,
    [switch] $ExportToDesktop
  )

  $users = Get-ADGroup -Filter "Name -like '$GroupNameFilter'" |
    ForEach-Object {
      $group = $_
      Get-ADGroupMember -Identity $group.Samaccountname |
        Select-Object  @{n = "Group"; e = { $group.Samaccountname } }, @{n = "Name"; e = { $_.Name } }, @{n = "Login"; e = { $_.Samaccountname } }
      }

  $report = $users |
    Format-Table Name, Login -GroupBy Group

  if ($ExportToDesktop) {
    $report |
      Out-File "~/Desktop/Groups_$(Get-Date -Format yyyy-MM-dd).txt"
  } else {
    $report
  }
}
