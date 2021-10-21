(Get-Content ./worktype.xml).TraceData.Events.Event.Column | where {$_.name -eq 'TextData' -and $_.'#text'.StartsWith('UPDATE')} | select -ExpandProperty '#text' | out-file out.sql
