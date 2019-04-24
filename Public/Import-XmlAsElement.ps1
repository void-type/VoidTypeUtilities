function Import-XmlAsElement {
  <#
    .SYNOPSIS
    Imports any XML as an XML element.

    .EXAMPLE
    Import-XmlAsElement -Path "C:\Users\Me\Desktop\somefile.xml"
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  return ([xml](Get-Content "$Path")).get_DocumentElement()
}
